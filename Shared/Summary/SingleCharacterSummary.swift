//
//  SingleCharacterSummary.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 06/10/2020.
//

import SwiftUI

struct SingleCharacterSummary: View {
    @EnvironmentObject var farmOrder: FarmCollectionsOrder
    @EnvironmentObject var gameData: GameData
    
    let summarySize: summaryPreviewSize
    let character: CharacterInProfile
    let characterEncounters: CharacterRaidEncounters
    
    @State var notableRaids: [CombinedRaidWithEncounters]   = []
    @State var notableRaidsLoot: [InstanceNotableItems]     = []
    
    @State var message: String = "Loading…"
    
    var body: some View {
        HStack(spacing:0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(character.name) - \(character.realm.name)")
                    .font(.title2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.25)
                    .whiteTextWithBlackOutlineStyle()
                Text("\(character.level) - \(character.playableRace.name), \(character.playableClass.name)")
                    .whiteTextWithBlackOutlineStyle()
            }
            .padding()
            Spacer()
        }
        .background(
            CharacterListItemBackground(
                charClass: character.playableClass,
                faction: character.faction,
                selected: false
            )
        )
        .cornerRadius(5)
        .padding()
        if notableRaids.count > 0 {
//            NoFarmingLeft(summarySize: summarySize, character: character)
            SummaryOfNotableRaids(summarySize: summarySize, character: character, notableRaids: notableRaids, loot: notableRaidsLoot)
            
        } else if message == "Loading…" {
            
            Text(message)
                .padding()
                .onAppear(perform: {
                    DispatchQueue.main.async {
                        combineCharacterEncountersWithData()
                    }
                })
        } else {
            NoFarmingLeft(summarySize: summarySize, character: character)
                .padding(.horizontal)
        }
        
    }
    
    func combineCharacterEncountersWithData() {
        guard gameData.raids.count > 0 else { return }
        let raidDataManipulator = RaidDataHelper()
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
    
    /// Checks if the raid is worth raiding, by looking through it's encounters, and seeing if the loot from it is a mount or pet
    /// - Parameter raid: CombinedRaidWithEncounters <- raid info from the Player
    /// - Returns: True or False - just for decision
    func isRaidWorthFarming(_ raid: CombinedRaidWithEncounters) -> Bool {
        let raidDataManipulator = RaidDataHelper()
        
        var mounts: [QualityItemStub] = []
        var pets: [QualityItemStub] = []
        
        for encounter in raid.records.first!.progress.encounters {
            if raidDataManipulator.isEncounterCleared(encounter) { break }
            
            let loot = gameData.raidEncounters.first { (journalEncounter) -> Bool in
                journalEncounter.id == encounter.encounter.id
            }
            
            guard let currentEncounterWithLoot = loot else { return false }
            
            for wrapper in currentEncounterWithLoot.items {
                if gameData.mountItemsList.contains(where: { (mount) -> Bool in
                    mount.itemID == wrapper.item.id
                }) {
                    let currentMount = QualityItemStub(name: wrapper.item.name, id: wrapper.item.id, quality: .epic)
                    mounts.append(currentMount)
                } else if gameData.petItemsList.contains(where: { (pet) -> Bool in
                    pet.itemID == wrapper.item.id
                }) {
                    let currentPet = QualityItemStub(name: wrapper.item.name, id: wrapper.item.id, quality: .uncommon)
                    pets.append(currentPet)
                }
            }
        }
        
        if mounts.count + pets.count > 0 {
            let lootForRaid = InstanceNotableItems(id: raid.id, mounts: mounts, pets: pets)
            notableRaidsLoot.append(lootForRaid)
            return true
        } else {
            return false
        }
    }
    
    
}


