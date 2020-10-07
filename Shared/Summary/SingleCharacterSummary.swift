//
//  SingleCharacterSummary.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 06/10/2020.
//

import SwiftUI

struct SingleCharacterSummary: View {
    @EnvironmentObject var farmOrder: FarmCollectionsOrder
    @EnvironmentObject var gameData: GameData
    
    let characterEncounters: CharacterRaidEncounters
    
    @State var notableRaids: [CombinedRaidWithEncounters] = []
    
    @State var message: String = "Loading…"
    
    var body: some View {
        
        if notableRaids.count > 0 {
            Text(characterEncounters.character.name)
            VStack{
                ForEach(notableRaids, id: \.raidId) { raid in
                    Text(raid.raidName)
                }
            }.padding()
        } else {
            Text(message)
                .padding()
                .onAppear(perform: {
                    DispatchQueue.main.async {
                        combineCharacterEncountersWithData()
                    }
                })
        }
        
    }
    
    func getCharacterBasedOn(encounters: CharacterRaidEncounters) -> CharacterInProfile {
        let character = gameData.characters.first { (GDCharacter) -> Bool in
            GDCharacter.name == encounters.character.name && GDCharacter.realm.name == encounters.character.realm.name
        }
        
        
        return character!
    }
    
    func combineCharacterEncountersWithData() {
        guard gameData.raids.count > 0 else { return }
        let raidDataManipulator = RaidDataHelper()
        let character = getCharacterBasedOn(encounters: characterEncounters)
        let combinedRaidInfo = raidDataManipulator.createFullRaidData(using: characterEncounters, with: gameData, filter: .highest, filterForFaction: character.faction)
        
        var allDataCombined = RaidDataFilledAndSorted(basedOn: combinedRaidInfo, for: character, farmingOrder: farmOrder)
        
        allDataCombined.prepareForSummary()
        
        var allRaids: [CombinedRaidWithEncounters] = []
        
        allDataCombined.raidsCollection.forEach { (raidCollection) in
            allRaids.append(contentsOf: raidCollection.raids)
        }
        
        if allRaids.count == 0 {
            message = "No notable raids with loot left for \(character.name)"
            return
        }
        
        var raidsWorthFarming: [CombinedRaidWithEncounters] = []
        
        for raid in allRaids {
            if raidsWorthFarming.count < 4 {
                if isRaidWorthFarming(raid) {
                    raidsWorthFarming.append(raid)
                }
            } else {
                break
            }
        }
        withAnimation {
            notableRaids.append(contentsOf: raidsWorthFarming)
        }
    }
    
    func isRaidWorthFarming(_ raid: CombinedRaidWithEncounters) -> Bool {
        let raidDataManipulator = RaidDataHelper()
        
        var worthFarming: Bool = false
        
        for encounter in raid.records.first!.progress.encounters {
            let loot = gameData.raidEncounters.first { (journalEncounter) -> Bool in
                journalEncounter.id == encounter.encounter.id
            }
            
            guard let currentEncounterWithLoot = loot else { return false }
            
            for wrapper in currentEncounterWithLoot.items {
                if gameData.mountItemsList.contains(where: { (mount) -> Bool in
                    mount.id == wrapper.item.id
                }) {
                    worthFarming = true
                }
                if gameData.petItemsList.contains(where: { (pet) -> Bool in
                    pet.id == wrapper.item.id
                }) {
                    worthFarming = true
                }
            }
            
            if worthFarming && raidDataManipulator.isEncounterCleared(encounter) {
                worthFarming = false
            }
            
            if worthFarming {
                return true
            }
            
        }
        
        return false
    }
    
    
}
