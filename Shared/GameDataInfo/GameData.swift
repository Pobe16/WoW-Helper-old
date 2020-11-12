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
    let mountItemsList: [CollectibleItem]                               = createMountsList()
    let petItemsList: [CollectibleItem]                                 = createPetsList()
    var mountsStillToObtain: [CollectibleItem]                          = []
    var petsStillToObtain: [CollectibleItem]                            = []
    
    @Published var characters: [CharacterInProfile]                     = []
    
    @Published var ignoredCharacters: [CharacterInProfile]              = []
                
    var expansionsStubs: [ExpansionIndex]                               = []
    @Published var expansions: [ExpansionJournal]                       = []
                
    var raidsStubs: [InstanceIndex]                                     = []
    @Published var raids: [InstanceJournal]                             = []
                
    var raidEncountersStubs: [Int]                                      = []
    @Published var raidEncounters: [JournalEncounter]                   = []
            
    var charactersForRaidEncounters: [CharacterInProfile]               = []
    @Published var characterRaidEncounters: [CharacterRaidEncounters]   = []
    
    let estimatedItemsToDownload: Int                                   = 100
    @Published var actualItemsToDownload: Int                           = 0
    @Published var downloadedItems: Int                                 = 1
                
    @Published var loadingAllowed: Bool                                 = true
    
    init () {
        // THIS NEEDS UPDATED FOR SHADOWLANDS
//        guard let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String  else {
//            return
//        }
        // preload the British English

//        if requestLocale == EuropeanLocales.BritishEnglish {
//            raids = createRaidsList()
//        }
        
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
            self.raidEncountersStubs.removeAll()
            self.raidEncounters.removeAll()
            self.charactersForRaidEncounters.removeAll()
            
            self.downloadedItems = 1
            self.actualItemsToDownload = 0
            
            withAnimation {
                self.characters.removeAll()
                self.expansions.removeAll()
                self.raids.removeAll()
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
        
        if timeRetries > 3 || connectionRetries > 3 {
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
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                
                // something went wrong, check the error
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                loadCharacters()
                
                return
            }
            
            connectionRetries = 0
            decodeCharactersData(data, fromURL: fullRequestURL)
            
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
            
            var accountCharacters: [CharacterInProfile] = []
            
            for account in accounts {
                accountCharacters.append(contentsOf: account.characters)
            }
            
            addOrderToCharacters(accountCharacters)
            
        } catch {
            print(error)
        }
    }
    
    func addOrderToCharacters(_ downloadedCharacters: [CharacterInProfile]) {
        var accountCharacters: [CharacterInProfile] = []
        var accountIgnoredCharacters: [CharacterInProfile] = []
        
        for var character in downloadedCharacters {
            let currentCharacterOrder = UserDefaults.standard.integer(forKey: "\(UserDefaultsKeys.characterOrder)\(character.name)\(character.id)\(character.realm.slug)")
            character.order = currentCharacterOrder
            if character.order! > 999 {
                accountIgnoredCharacters.append(character)
            } else {
                accountCharacters.append(character)
            }
        }
        
        accountCharacters.sort { (lhs, rhs) -> Bool in
            lhs.order! < rhs.order!
        }
        
        accountIgnoredCharacters.sort { (lhs, rhs) -> Bool in
            lhs.name < rhs.name
        }
        
        if accountCharacters.count > 0 {
            for i in 1...accountCharacters.count - 1 {
                if accountCharacters[i].order == 0 {
                    accountCharacters[i].order = i
                    let character = accountCharacters[i]
                    UserDefaults.standard.setValue(i, forKey: "\(UserDefaultsKeys.characterOrder)\(character.name)\(character.id)\(character.realm.slug)")
                }
            }
        }
        
        DispatchQueue.main.async { [self] in
            withAnimation {
                characters = accountCharacters
            }
            
            ignoredCharacters = accountIgnoredCharacters
            
            charactersForRaidEncounters.append(contentsOf: accountCharacters.filter({ (character) -> Bool in
                character.level >= 30
            }))
            
            actualItemsToDownload += charactersForRaidEncounters.count
            print("finished loading characters")
            print("loaded \(characters.count) characters, including \(charactersForRaidEncounters.count) in raiding level")
            loadAccountMounts()
        }
    }
    
    func changeCharactersOrder(from source: IndexSet, to destination: Int) {
        characters.move(fromOffsets: source, toOffset: destination)
        
        rewriteOrders()
        
        DispatchQueue.main.async { [self] in
            withAnimation {
                characterRaidEncounters.sort { characterRaidEncountersSorting(lhs: $0, rhs: $1) }
            }
        }
    }
    
    private func rewriteOrders(){
        characters.forEach { (item) in
            let newOrder = characters.firstIndex(of: item)
            if newOrder != nil {
                characters[newOrder!].order = newOrder!
            }
            UserDefaults.standard.setValue(newOrder!, forKey: "\(UserDefaultsKeys.characterOrder)\(item.name)\(item.id)\(item.realm.slug)")
        }
    }
    
    func ignoreCharacter(at offsets: IndexSet) {
        var characterToIgnore = characters.remove(at: offsets.first!)
        characterToIgnore.order! += 1000
        ignoredCharacters.append(characterToIgnore)
        
        UserDefaults.standard.setValue(characterToIgnore.order!, forKey: "\(UserDefaultsKeys.characterOrder)\(characterToIgnore.name)\(characterToIgnore.id)\(characterToIgnore.realm.slug)")
        DispatchQueue.main.async { [self] in
            withAnimation {
                characterRaidEncounters.removeAll { (characterEncounters) -> Bool in
                    characterEncounters.character.name == characterToIgnore.name &&
                    characterEncounters.character.id == characterToIgnore.id &&
                    characterEncounters.character.realm.slug == characterToIgnore.realm.slug
                }
            }
            rewriteOrders()
        }
    }
    
    func unIgnoreCharacter(_ character: CharacterInProfile) {
        let index = ignoredCharacters.firstIndex(of: character) ?? 0
        var characterToPutBack = ignoredCharacters[index]
        characterToPutBack.order! -= 1000
        
        DispatchQueue.main.async { [self] in
            withAnimation {
                ignoredCharacters.remove(at: index)
                characters.append(characterToPutBack)
            }
            rewriteOrders()
            UserDefaults.standard.setValue(characterToPutBack.order!, forKey: "\(UserDefaultsKeys.characterOrder)\(characterToPutBack.name)\(characterToPutBack.id)\(characterToPutBack.realm.slug)")
            if characterToPutBack.level >= 30 {
                reloadCharacterRaidEncounters(for: characterToPutBack)
            }
        }
        
        
    }
    
    func loadAccountMounts() {
        
        if timeRetries > 3 || connectionRetries > 3 {
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
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                
                // something went wrong, check the error
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                loadAccountMounts()
                
                return
            }
            
            connectionRetries = 0
            decodeAccountMounts(data, fromURL: fullRequestURL)
            
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
            print("Error while decoding mounts")
            print(error)
            loadAccountPets()
        }
    }
    
    func loadAccountPets() {
        
        if timeRetries > 3 || connectionRetries > 3 {
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
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                // something went wrong, check the error
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                loadAccountPets()
                return
            }
            
            decodeAccountPets(data, fromURL: fullRequestURL)
            
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
            print("Error while decoding pets")
            print(error)
            loadExpansionIndex()
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
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            self.decodeExpansionIndexData(data, fromURL: fullRequestURL)
            
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
            print("Error while decoding expansion Index Data")
            print(error)
        }
    }
    
    private func loadExpansionJournal() {
        
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            
            timeRetries = 0
            connectionRetries = 0
            
            if expansionsStubs.count > 0 {
                expansionsStubs.removeFirst()
            }
            
            loadExpansionJournal()
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
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadExpansionJournal()
                }
                return
            }
            
            timeRetries = 0
            connectionRetries = 0
            
            decodeExpansionJournalData(data, fromURL: fullRequestURL)
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
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            if self.raidsStubs.count > 0 {
                self.raidsStubs.removeFirst()
            }
            self.loadRaidsInfo()
            
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
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                print("error, retrying in 1 second")
                print(error?.localizedDescription ?? "error")
                self.connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadRaidsInfo()
                }
                return
            }
            
            connectionRetries = 0
            DispatchQueue.main.async {
                decodeRaidData(data, fromURL: fullRequestURL)
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
            
            
            timeRetries = 0
                
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
            timeRetries += 1
            print(error)
            loadRaidsInfo()
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
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            if raidEncounters.count > 0 {
                raidEncounters.removeFirst()
            }
            loadRaidEncountersInfo()
            
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
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadRaidEncountersInfo()
                }
                return
            }
            self.connectionRetries = 0
            
            DispatchQueue.main.async {
                self.decodeRaidEncountersData(data, fromURL: URLIdentifier)
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
            
            timeRetries = 0
                
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
            timeRetries += 1
            print(error)
            loadRaidEncountersInfo()
        }
    }
    
    func reloadCharacterRaidEncounters(for character: CharacterInProfile) {
        reloadFromCDAllowed = false
        
        DispatchQueue.main.async {
            self.characterRaidEncounters.removeAll { (encountersCharacter) -> Bool in
                encountersCharacter.character.id == character.id &&
                encountersCharacter.character.name == character.name &&
                encountersCharacter.character.realm.slug == character.realm.slug
            }
            self.charactersForRaidEncounters.append(character)
            self.loadCharacterRaidEncounters()
        }
    }
    
    private func characterRaidEncountersSorting(lhs: CharacterRaidEncounters, rhs: CharacterRaidEncounters) -> Bool {
        let lhsCharacter = characters.first { (baseCharacter) -> Bool in
            lhs.character.id == baseCharacter.id
        }
        let rhsCharacter = characters.first { (baseCharacter) -> Bool in
            rhs.character.id == baseCharacter.id
        }
        return lhsCharacter!.order! < rhsCharacter!.order!
    }
    
    func loadCharacterRaidEncounters() {
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            if charactersForRaidEncounters.count > 0 {
                charactersForRaidEncounters.removeFirst()
            }
            if charactersForRaidEncounters.count > 0 {
                loadCharacterRaidEncounters()
            }
            
            DispatchQueue.main.async { [self] in
                withAnimation {
                    loadingAllowed = true
                }
                reloadFromCDAllowed = true
            }
            return
        }
        
        guard let character = charactersForRaidEncounters.first else {
            if characterRaidEncounters.count > 0 {
                print("finished loading character raid encounters")
                print("loaded \(characterRaidEncounters.count) character raid encounters")
                
                DispatchQueue.main.async { [self] in
                    withAnimation {
                        characterRaidEncounters.sort { characterRaidEncountersSorting(lhs: $0, rhs: $1) }
                        loadingAllowed = true
                    }
                    reloadFromCDAllowed = true
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
        
        let encodedName = character.name.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let requestUrlAPIFragment =
            "/profile/wow/character" +
            "/\(character.realm.slug)" +
            "/\(encodedName ?? character.name.lowercased())" +
            "/encounters/raids"
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
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadCharacterRaidEncounters()
                }
                return
            }
            
            connectionRetries = 0
            decodeCharacterRaidEncountersData(data, fromURL: fullRequestURL)
            
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
            
            
            timeRetries = 0
            
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
            timeRetries += 1
            print(error)
            loadCharacterRaidEncounters()
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
    
//    func updateDungeonInstanceBackground(for instance: InstanceJournal, with data: Data) {
//        guard let indexToUpdate = dungeons.firstIndex(where: { (dungeonsInstance) -> Bool in
//            return dungeonsInstance.id == instance.id && dungeonsInstance.expansion.id == instance.expansion.id
//        }) else { return }
//        dungeons[indexToUpdate].background = data
//    }
    
    func updateRaidCombinedBackground(for raid: CombinedRaidWithEncounters, with data: Data) {
        guard let indexToUpdate = raids.firstIndex(where: { (raidInstance) -> Bool in
            return raidInstance.id == raid.id && raidInstance.expansion.id == raid.expansion.id
        }) else { return }
        raids[indexToUpdate].background = data
    }
    
}

