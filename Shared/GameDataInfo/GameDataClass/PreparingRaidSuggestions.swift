//
//  PreparingRaidSuggestions.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 16/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    
    func prepareSuggestedRaids() {
        clearBeforeLoading()
        
        for characterEncounters in characterRaidEncounters {
            combineCharacterEncountersWithData(characterEncounters)
        }
        
        lootToDownload = Array(Set(lootToDownload))
        print("loot to download: \(lootToDownload.count)")
        
        loadLootMedia()
    }
    
    func clearBeforeLoading() {
        incompleteNotableRaids.removeAll()
        incompleteLootInRaids.removeAll()
        lootToDownload.removeAll()
        downloadedLoot.removeAll()
        DispatchQueue.main.async {
            withAnimation {
                self.raidSuggestions.removeAll()
            }
        }
    }
    
    func combineCharacterEncountersWithData(_ characterEncounters: CharacterRaidEncounters) {
        let raidDataManipulator = RaidDataHelper()
        let character = characters.first { (character) -> Bool in
            return  character.id == characterEncounters.character.id &&
                character.realm.slug == characterEncounters.character.realm.slug
        }!
        
        let encodedName = character.name.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let identifiableImageName = "\(UserDefaultsKeys.characterAvatar)-\(encodedName ?? character.name.lowercased())-\(character.realm.slug)"
        
        let combinedRaidInfo = raidDataManipulator.createFullRaidData(using: characterEncounters, with: self, filter: .highest, filterForFaction: character.faction)
        
        var allDataCombined = RaidDataFilledAndSorted(basedOn: combinedRaidInfo, for: character, farmingOrder: FarmCollectionsOrder())
        
        allDataCombined.prepareForSummary()
        
        var allRaids: [CombinedRaidWithEncounters] = []
        
        allDataCombined.raidsCollection.forEach { (raidCollection) in
            allRaids.append(contentsOf: raidCollection.raids)
        }
        
        var raidsWorthFarming: [RaidSuggestion] = []

        for raid in allRaids {
            if raidsWorthFarming.count < 6 {
                if isRaidWorthFarming(raid, for: character) {
                    let instanceNameTransformed = raid.raidName.lowercased().replacingOccurrences(of: " ", with: "-")
                    let nameForImage = "\(instanceNameTransformed)-\(raid.raidId)-\(CoreDataIDFragments.instanceBackground)"
                    
                    let incompleteRaidToSuggest = RaidSuggestion(raidID: raid.raidId, raidName: raid.raidName, raidImageURI: nameForImage, items: [])
                    raidsWorthFarming.append(incompleteRaidToSuggest)
                }
            }
        }
        
        let characterRaidsWithNoIcons = RaidsSuggestedForCharacter(
            characterID: character.id,
            characterName: character.name,
            characterLevel: character.level,
            characterRealmSlug: character.realm.slug,
            characterAvatarURI: identifiableImageName,
            characterFaction: character.faction.type,
            raids: raidsWorthFarming
        )
        
        incompleteNotableRaids.removeAll { (suggestion) -> Bool in
            return  suggestion.characterName == characterRaidsWithNoIcons.characterName &&
                    suggestion.characterID == characterRaidsWithNoIcons.characterID &&
                    suggestion.characterRealmSlug == characterRaidsWithNoIcons.characterRealmSlug
        }
        incompleteNotableRaids.append(characterRaidsWithNoIcons)
        
    }
    
    /// Checks if the raid is worth raiding, by looking through it's encounters, and seeing if the loot from it is a mount or pet
    /// - Parameter raid: CombinedRaidWithEncounters <- raid info from the Player
    /// - Returns: True or False - just for decision
    func isRaidWorthFarming(_ raid: CombinedRaidWithEncounters, for character: CharacterInProfile) -> Bool {
        let raidDataManipulator = RaidDataHelper()
        
        let GDMounts    = mountsStillToObtain.count > 0 ? mountsStillToObtain : mountItemsList
        let GDPets      = petsStillToObtain.count > 0 ? petsStillToObtain : petItemsList
        
        var mounts: [QualityItemStub] = []
        var pets: [QualityItemStub] = []
        
        for encounter in raid.records.first!.progress.encounters {
            if raidDataManipulator.isEncounterCleared(encounter) { break }
            
            let loot = raidEncounters.first { (journalEncounter) -> Bool in
                journalEncounter.id == encounter.encounter.id
            }
            
            guard let currentEncounterWithLoot = loot else { return false }
            
            for wrapper in currentEncounterWithLoot.items {
                if GDMounts.contains(where: { (mount) -> Bool in
                    mount.itemID == wrapper.item.id
                }) {
                    let currentMount = QualityItemStub(name: wrapper.item.name, id: wrapper.item.id, quality: .epic)
                    mounts.append(currentMount)
                } else if GDPets.contains(where: { (pet) -> Bool in
                    pet.itemID == wrapper.item.id
                }) {
                    let currentPet = QualityItemStub(name: wrapper.item.name, id: wrapper.item.id, quality: .uncommon)
                    pets.append(currentPet)
                }
            }
        }
        
        if (mounts.count + pets.count) > 0 {
            let lootForRaid = CharacterInstanceNotableItems(characterID: character.id, characterName: character.name, characterRealmSlug: character.realm.slug, raidID: raid.id, mounts: mounts, pets: pets)
            incompleteLootInRaids.append(lootForRaid)
            lootToDownload.append(contentsOf: mounts)
            lootToDownload.append(contentsOf: pets)
            return true
        } else {
            return false
        }
    }
    
    func loadLootMedia() {
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            if lootToDownload.count > 0 {
                print("removing because error:", lootToDownload.first ?? "unknown error")
                lootToDownload.removeFirst()
            }
            if lootToDownload.count > 0 {
                loadLootMedia()
                return
            }
            
            if !downloadedLoot.isEmpty {
                DispatchQueue.main.async {
                    self.prepareSuggestedRaids()
                }
            }
            return
        }
        
        guard let currentItem = lootToDownload.first else {
            if downloadedLoot.count > 0 {
                print("finished loading loot media items")
                
                print("loaded \(downloadedLoot.count) loot media items")
                
                combineNotableRaidsWithLoot()
                
                return
            }
            timeRetries += 1
            print("data saving problem with loot media items - retrying in 1s")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadLootMedia()
            }
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/media/item" +
            "/\(currentItem.id)"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "static-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? APIRegionHostList.Europe
        
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let strippedAPIUrl = requestUrlAPIHost + requestUrlAPIFragment
        
        let daysNeededForRefresh: Double = reloadFromCDAllowed ? 90 : 0.0
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: daysNeededForRefresh) {
            
            decodeItemMedia(item: currentItem, media: savedData.data!)
            
            return
        }
        
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
                    loadLootMedia()
                }
                return
            }
            
            decodeItemMedia(item: currentItem, media: data, fromURL: fullRequestURL)
            
        }
        task.resume()
    }
    
    func decodeItemMedia(item: QualityItemStub, media data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        do {
            let dataResponse = try decoder.decode(BlizzardMediaFormat.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            downloadIcon(for: item, using: dataResponse)
            
        } catch {
            timeRetries += 1
            print("error decoding media format", error)
            loadLootMedia()
        }
    }
    
    func downloadIcon(for item: QualityItemStub, using media: BlizzardMediaFormat) {
        guard let iconMedia = media.assets.first(where: { (asset) -> Bool in
            asset.key == "icon"
        }) else {
            connectionRetries += 1
            print("error finding icon in media", media)
            loadLootMedia()
            return
        }
        let iconAddress = iconMedia.value
        let iconURL = URL(string: iconMedia.value)!
        
        guard CoreDataImagesManager.shared.fetchImage(withName: iconAddress, maximumAgeInDays: 90) != nil else {
            
            let dataTask = URLSession.shared.dataTask(with: iconURL) { [self] data, response, error in
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data else {
                    connectionRetries += 1
                    print("error downloadingIcon")
                    loadLootMedia()
                    return
                    
                }
                
                CoreDataImagesManager.shared.updateImage(name: iconAddress, data: data)
                
                saveIconAddress(iconAddress, for: item)
                
            }
            dataTask.resume()
            return
        }
        
        saveIconAddress(iconAddress, for: item)
    }
    
    func saveIconAddress(_ address: String, for item: QualityItemStub) {
        
        let itemWithIconAddress = QualityItemStubWithIconAddress(
            name: item.name, id: item.id, quality: item.quality, iconURI: address
        )
        
        downloadedLoot.append(itemWithIconAddress)
        
        if lootToDownload.count > 0 {
            lootToDownload.removeFirst()
        }
        
        connectionRetries = 0
        timeRetries = 0
        
        loadLootMedia()
    }
    
    func combineNotableRaidsWithLoot() {
        
        print("loot downloaded \(downloadedLoot.count)")
        guard incompleteNotableRaids.count > 0 else {
            return
        }
        
        for character in incompleteNotableRaids {
            var raids: [RaidSuggestion] = []
            
            for raid in character.raids {
                let currentLoot = incompleteLootInRaids.first { (lootWrapper) -> Bool in
                    return lootWrapper.characterID == character.characterID &&
                        lootWrapper.characterName == character.characterName &&
                        lootWrapper.characterRealmSlug == character.characterRealmSlug &&
                        lootWrapper.raidID == raid.raidID
                }
                
                if currentLoot == nil {
                    continue
                }
                
                var mounts: [RaidSuggestionItem]    = []
                var pets: [RaidSuggestionItem]      = []
                
                for mount in currentLoot!.mounts {
                    
                    let downloaded = downloadedLoot.first { (item) -> Bool in
                        item.id == mount.id
                    }
                    
                    let mountToAdd = RaidSuggestionItem(id: mount.id, name: mount.name.value, quality: mount.quality, iconURI: downloaded?.iconURI ?? "")
                    mounts.append(mountToAdd)
                    
                }
                
                for pet in currentLoot!.pets {
                    
                    let downloaded = downloadedLoot.first { (item) -> Bool in
                        item.id == pet.id
                    }
                    
                    let petToAdd = RaidSuggestionItem(id: pet.id, name: pet.name.value, quality: pet.quality, iconURI: downloaded?.iconURI ?? "")
                    pets.append(petToAdd)
                    
                }
                
                
                
                let raidToAdd = RaidSuggestion(raidID: raid.raidID, raidName: raid.raidName, raidImageURI: raid.raidImageURI, items: mounts + pets)
                
                raids.append(raidToAdd)
            }
            
            let characterSuggestions =
                RaidsSuggestedForCharacter(
                    characterID: character.characterID,
                    characterName: character.characterName,
                    characterLevel: character.characterLevel,
                    characterRealmSlug: character.characterRealmSlug,
                    characterAvatarURI: character.characterAvatarURI,
                    characterFaction: character.characterFaction,
                    raids: raids
                )
            
            DispatchQueue.main.async {
                withAnimation {
                    self.raidSuggestions.append(characterSuggestions)
                }
            }
            
        }
    }
}
