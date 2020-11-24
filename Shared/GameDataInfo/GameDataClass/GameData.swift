//
//  GameData.swift
//  WoWHelper  (iOS)
//
//  Created by Mikolaj Lukasik on 20/08/2020.
//

import Foundation
import SwiftUI

class GameData: ObservableObject {
    @AppStorage(UserDefaultsKeys.raidSuggestions, store: UserDefaults(suiteName: UserDefaultsKeys.appUserGroup))
    var raidSuggestionsData: Data                                       = Data()
    
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
    
    var incompleteNotableRaids: [RaidsSuggestedForCharacter]            = []
    var incompleteLootInRaids: [CharacterInstanceNotableItems]          = []
    var lootToDownload: [QualityItemStub]                               = []
    var downloadedLoot: [QualityItemStubWithIconAddress]                = []
    @Published var raidSuggestions: [RaidsSuggestedForCharacter]        = []
    
    init() {
        
    }
}

