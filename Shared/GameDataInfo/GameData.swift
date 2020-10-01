//
//  GameData.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 20/08/2020.
//

import Foundation
import SwiftUI

class GameData: ObservableObject {
    var authorization: Authentication                       = Authentication()
    var timeRetries                                         = 0
    var connectionRetries                                   = 0
    var reloadFromCDAllowed                                 = true
    var loadDungeonsToo                                     = false
    var mountItemsList: [MountItem]                         = createMountsList()
    var petItemsList: [PetItem]                             = createPetsList()
    
    @Published var expansionsStubs: [ExpansionIndex]        = []
    @Published var expansions: [ExpansionJournal]           = []
    
    @Published var raidsStubs: [InstanceIndex]              = []
    @Published var raids: [InstanceJournal]                 = []
    
    @Published var dungeonsStubs: [InstanceIndex]           = []
    @Published var dungeons: [InstanceJournal]              = []
    
    @Published var raidEncountersStubs: [Int]               = []
    @Published var raidEncounters: [JournalEncounter]       = []
    
    let estimatedItemsToDownload: Int                       = 50
    @Published var actualItemsToDownload: Int               = 0
    @Published var downloadedItems: Int                     = 1
    
    @Published var loadingAllowed: Bool                     = true
    
    init () {
        
        guard let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String  else {
            return
        }
        
        if requestLocale == EuropeanLocales.BritishEnglish {
            raids = createRaidsList()
            dungeons = createDungeonsList()
        }
        
    }
    
    func deleteAllJSONData() {
        let allData = JSONCoreDataManager.shared.fetchAllJSONData()
        allData?.forEach({ item in
            JSONCoreDataManager.shared.deleteJSONData(data: item)
        })
    }
    
    func continueLoadingDungeons(authorizedBy auth: Authentication) {
        if !dungeonsStubs.isEmpty {
            loadDungeonsToo = true
            guard loadingAllowed else { return }
            actualItemsToDownload += dungeonsStubs.count
            loadingAllowed = false
            loadDungeonsInfo()
        }
    }
    
    func hardReloadGameData(authorizedBy auth: Authentication) {
        guard loadingAllowed else { return }
        reloadFromCDAllowed = false
        authorization = auth
        deleteDataBeforeUpdating()
    }
    
    private func deleteDataBeforeUpdating() {
        DispatchQueue.main.async {
            self.expansionsStubs.removeAll()
            self.raidsStubs.removeAll()
            self.dungeonsStubs.removeAll()
            self.raidEncountersStubs.removeAll()
            self.raidEncounters.removeAll()
            self.downloadedItems = 1
            self.actualItemsToDownload = 0
            
            withAnimation {
                self.expansions.removeAll()
                self.raids.removeAll()
                self.dungeons.removeAll()
                
            }
            self.loadExpansionIndex()
        }
    }
    
    func loadGameData(authorizedBy auth: Authentication) {
        guard expansions.count == 0 && loadingAllowed else { return }
        reloadFromCDAllowed = true
        authorization = auth
        
        if downloadedItems > 1 { downloadedItems = 1 }
        if actualItemsToDownload > 0 { actualItemsToDownload = 0}
        
        loadExpansionIndex()
    }
    
    private func loadExpansionIndex() {
        withAnimation {
            loadingAllowed = false
        }
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/journal-expansion/index"
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlAPIHost + requestUrlAPIFragment, maximumAgeInDays: 90) {
            decodeExpansionIndexData(savedData.data!)
            return
        }
        
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "static-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.decodeExpansionIndexData(data, fromURL: fullRequestURL)
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    private func decodeExpansionIndexData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionTop.self, from: data)
            print(dataResponse.tiers.count)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            DispatchQueue.main.async {
                self.expansionsStubs = dataResponse.tiers
                self.actualItemsToDownload += dataResponse.tiers.count
                self.loadExpansionJournal()
            }
            
            
        } catch {
            print(error)
        }
    }
    
    private func loadExpansionJournal() {
        
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            return
        }
        
        guard let stub = expansionsStubs.first else {
            if expansions.count > 0 {
                print("finished loading expansions")
                print("loaded \(expansions.count) expansions")
                DispatchQueue.main.async {
                    withAnimation {
                        self.expansions.sort()
                        self.actualItemsToDownload += self.raidsStubs.count
                        if self.loadDungeonsToo {
                            self.actualItemsToDownload += self.dungeonsStubs.count
                        }
                    }
                }
                
                loadRaidsInfo()
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("data saving problem - retrying in 1s")
                self.loadExpansionJournal()
            }
            return
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2.accessToken ?? ""
        
        let requestUrlAPIHost = "\(stub.key.href)"
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
                decodeExpansionJournalData(savedData.data!)
                return
            }
        }
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(accessToken)"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.timeRetries = 0
                self.connectionRetries = 0
                
                self.decodeExpansionJournalData(data, fromURL: fullRequestURL)
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
                self.connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.loadExpansionJournal()
                }
            }
        }
        task.resume()
        
        
    }
    
    private func decodeExpansionJournalData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionJournal.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async {
                
                withAnimation {
                    self.expansions.append(dataResponse)
                    self.downloadedItems += 1
                }
                
                self.raidsStubs.append(contentsOf: dataResponse.raids ?? [])
                self.dungeonsStubs.append(contentsOf: dataResponse.dungeons ?? [])
                
                if self.expansionsStubs.count > 0 {
                    self.expansionsStubs.removeFirst()
                }
                
                self.loadExpansionJournal()
            }
            
            
        } catch {
            print(error)
        }
    }
    
    private func loadRaidsInfo(){
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            return
        }
        guard let currentRaidToLoad = raidsStubs.first else {
            if raids.count > 0 {
                print("finished loading raids")
                print("loaded \(raids.count) raids")
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.raids.sort()
                    }
                    self.loadingAllowed = true
                    self.reloadFromCDAllowed = true
                    self.prepareRaidEncounters()
                }
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadRaidsInfo()
            }
            return
        }
        
        guard !raids.contains(where: { (raid) -> Bool in
            currentRaidToLoad.id == raid.id
        }) else {
            if raidsStubs.count > 0 {
                raidsStubs.removeFirst()
            }
            loadRaidsInfo()
            return
        }
        
        let requestUrlAPIHost = "\(currentRaidToLoad.key.href)"
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
            
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
                decodeRaidData(savedData.data!)
                return
            }
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2.accessToken ?? ""
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(accessToken)"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.timeRetries = 0
                self.connectionRetries = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.decodeRaidData(data, fromURL: fullRequestURL)
                }
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error.localizedDescription)
                self.connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.loadRaidsInfo()
                }
            }
        }
        task.resume()
        
    }
    private func decodeRaidData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(InstanceJournal.self, from: data)
            
//          For some reason Blizz have put a Greater Legion Invasion here as a raid…
//          I'm not allowing it.
            if dataResponse.category.type == .event {
                if raidsStubs.count > 0{
                    raidsStubs.removeFirst()
                }
                loadRaidsInfo()
                return
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async {
                withAnimation {
                    if !self.raids.contains(where: { (instance) -> Bool in
                        instance.id == dataResponse.id
                    }) {
                        self.raids.append(dataResponse)
                    }
                    self.downloadedItems += 1
                }
                if self.raidsStubs.count > 0 {
                    self.raidsStubs.removeFirst()
                }
                self.loadRaidsInfo()
            }
            
        } catch {
            print(error)
        }
    }
    
    private func loadDungeonsInfo(){
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            return
        }
        guard let currentDungeonToLoad = dungeonsStubs.first else {
            if dungeons.count > 0 {
                print("finished loading dungeons")
                // some dungeons are doubled, as they were "refreshed" in newer expansions,
                // but it does not reflect in their "expansion id", just in the expansion journal
                // here I am removing duplicates, and sorting it
                let noDuplicates = Array(Set(dungeons))

                DispatchQueue.main.async {
                    withAnimation {
                        self.dungeons = noDuplicates.sorted()
                        self.loadingAllowed = true
                    }
                    self.reloadFromCDAllowed = true
                }
                print("loaded \(dungeons.count) dungeons")
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadRaidsInfo()
            }
            return
        }
        
        guard !dungeons.contains(where: { (dungeon) -> Bool in
            currentDungeonToLoad.id == dungeon.id
        }) else {
            if dungeonsStubs.count > 0 {
                dungeonsStubs.removeFirst()
            }
            loadDungeonsInfo()
            return
        }
        
        let requestUrlAPIHost = "\(currentDungeonToLoad.key.href)"
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
            
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
                    
                decodeDungeonData(savedData.data!)
                return
            }
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2.accessToken ?? ""
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(accessToken)"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.timeRetries = 0
                self.connectionRetries = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.decodeDungeonData(data, fromURL: fullRequestURL)
                }
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error.localizedDescription)
                self.connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.loadRaidsInfo()
                }
            }
        }
        task.resume()
        
    }
    
    private func decodeDungeonData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(InstanceJournal.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async {
                
                withAnimation {
                    self.dungeons.append(dataResponse)
                    self.downloadedItems += 1
                }
                
                if self.dungeonsStubs.count > 0 {
                    self.dungeonsStubs.removeFirst()
                }
                self.loadDungeonsInfo()
            }
            
        } catch {
            print(error)
        }
    }
    
    private func prepareRaidEncounters() {
        raids.forEach { (instance) in
            raidEncountersStubs.append(instance.id)
        }
        loadRaidEncountersInfo()
    }
    
    private func loadRaidEncountersInfo(){
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            return
        }
        guard let currentRaidEncountersToLoad = raidEncountersStubs.first else {
            if raidEncounters.count > 0 {
                print("finished loading raid encounters")

                DispatchQueue.main.async {
                    withAnimation {
                        self.raidEncounters = self.raidEncounters.sorted()
                        self.loadingAllowed = true
                    }
                    self.reloadFromCDAllowed = true
                }
                
                print("loaded \(raidEncounters.count) raid encounters")
                
                if self.loadDungeonsToo {
                    self.loadDungeonsInfo()
                } else {
                    print("loading dungeons postponed")
                }
                
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadRaidEncountersInfo()
            }
            return
        }
        
        guard !raidEncounters.contains(where: { (raidEncounter) -> Bool in
            currentRaidEncountersToLoad == raidEncounter.instance.id
        }) else {
            if raidEncounters.count > 0 {
                raidEncounters.removeFirst()
            }
            loadRaidEncountersInfo()
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/search/journal-encounter"
        let requestUrlSearchElement = "?instance.id=\(currentRaidEncountersToLoad)"
        let requestUrlIdentifiablePart = requestUrlAPIHost + requestUrlAPIFragment + requestUrlSearchElement
        let URLIdentifier = URL(string: requestUrlIdentifiablePart)!
        
        if reloadFromCDAllowed {
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlIdentifiablePart, maximumAgeInDays: 90) {
                decodeRaidEncountersData(savedData.data!)
                return
            }
        }
        
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "static-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlIdentifiablePart +
                                    "&namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.timeRetries = 0
                self.connectionRetries = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.decodeRaidEncountersData(data, fromURL: URLIdentifier)
                }
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error.localizedDescription)
                self.connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.loadRaidEncountersInfo()
                }
            }
        }
        task.resume()
        
    }
    
    private func decodeRaidEncountersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            let dataResponse = try decoder.decode(JournalEncounterSearch.self, from: data)
            let wrapper = dataResponse.results
            var results: [JournalEncounter] = []
            
            wrapper.forEach { (wrapper) in
                results.append(wrapper.data)
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async {
                
                withAnimation {
                    self.raidEncounters.append(contentsOf: results)
                    self.downloadedItems += 1
                }
                
                if self.raidEncountersStubs.count > 0 {
                    self.raidEncountersStubs.removeFirst()
                }
                self.loadRaidEncountersInfo()
            }
            
        } catch {
            print(error)
        }
    }
    
}
