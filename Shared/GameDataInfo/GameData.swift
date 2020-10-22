//
//  GameData.swift
//  WoWHelper  (iOS)
//
//  Created by Mikolaj Lukasik on 20/08/2020.
//

import Foundation
import SwiftUI

class GameData: ObservableObject {
    var authorization: Authentication                                   = Authentication()
    var timeRetries                                                     = 0
    var connectionRetries                                               = 0
    var reloadFromCDAllowed                                             = true
    var loadDungeonsToo                                                 = false
    let mountItemsList: [CollectibleItem]                               = createMountsList()
    let petItemsList: [CollectibleItem]                                 = createPetsList()
    var mountsStillToObtain: [CollectibleItem]                          = []
    var petsStillToObtain: [CollectibleItem]                            = []
    
    @Published var characters: [CharacterInProfile]                     = []
                
    var expansionsStubs: [ExpansionIndex]                               = []
    @Published var expansions: [ExpansionJournal]                       = []
                
    var raidsStubs: [InstanceIndex]                                     = []
    @Published var raids: [InstanceJournal]                             = []
                
    var dungeonsStubs: [InstanceIndex]                                  = []
    @Published var dungeons: [InstanceJournal]                          = []
                
    var raidEncountersStubs: [Int]                                      = []
    @Published var raidEncounters: [JournalEncounter]                   = []
            
    var charactersForRaidEncounters: [CharacterInProfile]               = []
    @Published var characterRaidEncounters: [CharacterRaidEncounters]   = []
    
    let estimatedItemsToDownload: Int                                   = 150
    @Published var actualItemsToDownload: Int                           = 0
    @Published var downloadedItems: Int                                 = 1
                
    @Published var loadingAllowed: Bool                                 = true
    
    init () {
        // THIS NEEDS UPDATED FOR SHADOWLANDS
//        guard let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String  else {
//            return
//        }
        // preload the British English raids and dungeons

//        if requestLocale == EuropeanLocales.BritishEnglish {
//            raids = createRaidsList()
//            dungeons = createDungeonsList()
//        }
        
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
            self.charactersForRaidEncounters.removeAll()
            
            self.downloadedItems = 1
            self.actualItemsToDownload = 0
            
            withAnimation {
                self.characters.removeAll()
                self.expansions.removeAll()
                self.raids.removeAll()
                self.dungeons.removeAll()
                self.characterRaidEncounters.removeAll()
            }
            self.loadCharacters()
        }
    }
    
    func loadGameData(authorizedBy auth: Authentication) {
        guard characters.count == 0 && loadingAllowed else { return }
        reloadFromCDAllowed = true
        authorization = auth
        
        if downloadedItems > 1 { downloadedItems = 1 }
        if actualItemsToDownload > 0 { actualItemsToDownload = 0}
        
        loadCharacters()
    }
    
    func loadCharacters() {
        withAnimation {
            loadingAllowed = false
        }
        
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/user/wow"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(fullRequestURL.absoluteString)
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.04) {
                decodeCharactersData(savedData.data!)
                return
            }
        }
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.decodeCharactersData(data, fromURL: fullRequestURL)
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
                self.connectionRetries += 1
                self.loadCharacters()
            }
        }
        task.resume()
    }
    
    func decodeCharactersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(UserProfile.self, from: data)
            
            guard let accounts = dataResponse.wowAccounts else {
                print("no wow accounts present")
                loadExpansionIndex()
                return
                
            }
            
            for account in accounts {
                DispatchQueue.main.async { [self] in
                    withAnimation {
                        characters.append(contentsOf: account.characters)
                    }
                    
                    charactersForRaidEncounters.append(contentsOf: characters.filter({ (character) -> Bool in
                        character.level >= 30
                    }))
                    actualItemsToDownload += charactersForRaidEncounters.count
                    print("finished loading characters")
                    print("loaded \(characters.count) characters, including \(charactersForRaidEncounters.count) in raiding level")
                    loadAccountMounts()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func loadAccountMounts() {
        
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/user/wow/collections/mounts"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(fullRequestURL.absoluteString)
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.1) {
                decodeAccountMounts(savedData.data!)
                return
            }
        }
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.decodeAccountMounts(data, fromURL: fullRequestURL)
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
                self.connectionRetries += 1
                self.loadAccountMounts()
            }
        }
        task.resume()
    }
    
    func decodeAccountMounts(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(MountsCollection.self, from: data)
            
            guard let mounts = dataResponse.mounts else {
                print("no account mounts present")
                loadExpansionIndex()
                return
                
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            var mountsNotYetObtained: [CollectibleItem] = []
            
            for dropMount in mountItemsList {
                if !mounts.contains(where: { (collectionMount) -> Bool in
                    collectionMount.mount.id == dropMount.collectionID
                }) {
                    mountsNotYetObtained.append(dropMount)
                }
            }
            
            mountsStillToObtain.append(contentsOf: mountsNotYetObtained)
            loadAccountPets()
            
            
        } catch {
            print(error)
        }
    }
    
    func loadAccountPets() {
        
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            loadExpansionIndex()
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/user/wow/collections/pets"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(fullRequestURL.absoluteString)
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.1) {
                decodeAccountMounts(savedData.data!)
                return
            }
        }
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.decodeAccountPets(data, fromURL: fullRequestURL)
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
                self.connectionRetries += 1
                self.loadAccountPets()
            }
        }
        task.resume()
    }
    
    func decodeAccountPets(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(PetsCollection.self, from: data)
            
            guard let pets = dataResponse.pets else {
                print("no account pets present")
                loadExpansionIndex()
                return
                
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            var petsNotYetObtained: [CollectibleItem] = []
            
            for dropPet in petItemsList {
                if !pets.contains(where: { (collectionPet) -> Bool in
                    collectionPet.species.id == dropPet.collectionID
                }) {
                    petsNotYetObtained.append(dropPet)
                }
            }
            
            petsStillToObtain.append(contentsOf: petsNotYetObtained)
            loadExpansionIndex()
            
        } catch {
            print(error)
        }
    }
    
    private func loadExpansionIndex() {
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/journal-expansion/index"
            
        if reloadFromCDAllowed {
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlAPIHost + requestUrlAPIFragment, maximumAgeInDays: 90) {
                decodeExpansionIndexData(savedData.data!)
                return
            }
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
            timeRetries = 0
            connectionRetries = 0
            return
        }
        
        guard let stub = expansionsStubs.first else {
            if expansions.count > 0 {
                print("finished loading expansions")
                print("loaded \(expansions.count) expansions")
                DispatchQueue.main.async { [self] in
                    withAnimation {
                        expansions.sort()
                        actualItemsToDownload += raidsStubs.count
                        if self.loadDungeonsToo {
                            actualItemsToDownload += dungeonsStubs.count
                        }
                    }
                    loadRaidsInfo()
                }
                
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
                
            DispatchQueue.main.async { [self] in
                
                withAnimation {
                    expansions.append(dataResponse)
                    downloadedItems += 1
                }
                
                raidsStubs.append(contentsOf: dataResponse.raids ?? [])
                dungeonsStubs.append(contentsOf: dataResponse.dungeons ?? [])
                
                if expansionsStubs.count > 0 {
                    expansionsStubs.removeFirst()
                }
                
                loadExpansionJournal()
            }
            
            
        } catch {
            print(error)
        }
    }
    
    private func loadRaidsInfo(){
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
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
            timeRetries = 0
            connectionRetries = 0
            return
        }
        guard let currentDungeonToLoad = dungeonsStubs.first else {
            if dungeons.count > 0 {
                print("finished loading dungeons")
                // some dungeons are doubled, as they were "refreshed" in newer expansions,
                // but it does not reflect in their "expansion id", just in the expansion journal
                // here I am removing duplicates, and sorting it
                let noDuplicates = Array(Set(dungeons))

                DispatchQueue.main.async { [self] in
                    withAnimation {
                        dungeons = noDuplicates.sorted()
                        loadingAllowed = true
                    }
                    reloadFromCDAllowed = true
                    print("loaded \(dungeons.count) dungeons")
                }
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
        DispatchQueue.main.async { [self] in
            withAnimation {
                actualItemsToDownload += raidEncountersStubs.count
            }
            loadRaidEncountersInfo()
        }
        
    }
    
    private func loadRaidEncountersInfo(){
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            return
        }
        guard let currentRaidEncountersToLoad = raidEncountersStubs.first else {
            if raidEncounters.count > 0 {
                print("finished loading raid encounters")

                DispatchQueue.main.async {
                    withAnimation {
                        self.raidEncounters = self.raidEncounters.sorted()
                    }
                }
                
                print("loaded \(raidEncounters.count) raid encounters")
                
                loadCharacterRaidEncounters()
                
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
    
    func loadCharacterRaidEncounters() {
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            DispatchQueue.main.async { [self] in
                withAnimation {
                    loadingAllowed = true
                }
                reloadFromCDAllowed = true
                
                if loadDungeonsToo {
                    loadDungeonsInfo()
                } else {
                    print("loading dungeons postponed")
                }
            }
            return
        }
        
        guard let character = charactersForRaidEncounters.first else {
            if characterRaidEncounters.count > 0 {
                print("finished loading character raid encounters")
                print("loaded \(characterRaidEncounters.count) character raid encounters")
                
                DispatchQueue.main.async { [self] in
                    withAnimation {
                        loadingAllowed = true
                    }
                    reloadFromCDAllowed = true
                    
                    if loadDungeonsToo {
                        loadDungeonsInfo()
                    } else {
                        print("loading dungeons postponed")
                    }
                }
                return
            }
            timeRetries += 1
            print("data saving problem with character encounters - retrying in 1s")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadCharacterRaidEncounters()
            }
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        
        let requestUrlAPIFragment =
            "/profile/wow/character"    + "/" +
            character.realm.slug        + "/" +
            character.name.lowercased() + "/" +
            "encounters/raids"
        let strippedAPIUrl = requestUrlAPIHost + requestUrlAPIFragment
        
        let daysNeededForRefresh: Double = reloadFromCDAllowed ? 0.01 : 0.0
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: daysNeededForRefresh) {
            
            decodeCharacterRaidEncountersData(savedData.data!)
            
            return
        }
        
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(fullRequestURL.absoluteString)
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.01) {
                decodeCharacterRaidEncountersData(savedData.data!)
                return
            }
        }
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            if let data = data {
//                print(data)
                timeRetries = 0
                connectionRetries = 0
                decodeCharacterRaidEncountersData(data, fromURL: fullRequestURL)
            }
            if let error = error {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error.localizedDescription)
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadCharacterRaidEncounters()
                }
            }
        }
        task.resume()
    }
        
    
    func decodeCharacterRaidEncountersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        do {
            let dataResponse = try decoder.decode(CharacterRaidEncounters.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            DispatchQueue.main.async { [self] in
                withAnimation {
                    characterRaidEncounters.append(dataResponse)
                    downloadedItems += 1
                }
                if charactersForRaidEncounters.count > 0 {
                    charactersForRaidEncounters.removeFirst()
                }
                loadCharacterRaidEncounters()
            }
            
            

        } catch {
            print(error)
        }
    }
    
    func updateCharacterAvatar(for character: CharacterInProfile, with data: Data) {
        guard let indexToUpdate = characters.firstIndex(where: { (charProfile) -> Bool in
            return charProfile.id == character.id && charProfile.realm.id == character.realm.id
        }) else { return }
        characters[indexToUpdate].avatar = data
    }
    
    func updateRaidInstanceBackground(for instance: InstanceJournal, with data: Data) {
        guard let indexToUpdate = raids.firstIndex(where: { (raidInstance) -> Bool in
            return raidInstance.id == instance.id && raidInstance.expansion.id == instance.expansion.id
        }) else { return }
        raids[indexToUpdate].background = data
    }
    
    func updateDungeonInstanceBackground(for instance: InstanceJournal, with data: Data) {
        guard let indexToUpdate = dungeons.firstIndex(where: { (dungeonsInstance) -> Bool in
            return dungeonsInstance.id == instance.id && dungeonsInstance.expansion.id == instance.expansion.id
        }) else { return }
        dungeons[indexToUpdate].background = data
    }
    
    func updateRaidCombinedBackground(for raid: CombinedRaidWithEncounters, with data: Data) {
        guard let indexToUpdate = raids.firstIndex(where: { (raidInstance) -> Bool in
            return raidInstance.id == raid.id && raidInstance.expansion.id == raid.expansion.id
        }) else { return }
        raids[indexToUpdate].background = data
    }
    
}

