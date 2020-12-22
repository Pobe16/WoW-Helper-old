//
//  CharacterRaidTile.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct CharacterRaidTile: View {    
    let raid: CombinedRaidWithEncounters
    let character: CharacterInProfile
    
    var body: some View {
        
        
//        NavigationLink( destination: RaidDetails(raid: raid, character: character) ) {
            VStack{
                HStack() {
                    Spacer()
                    Text("\(raid.raidName)")
                        .font(.title2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Spacer()
                }
                .padding(.vertical, 5)
                .background(
                    RaidTitleBackgroundBlur()
                )
                
                Spacer()
                VStack(spacing: 0) {
                    ForEach(filterModesForLegacyCompletion(in: raid), id: \.difficulty.name){ record in
                        HStack {
                            Text("\(record.difficulty.name)")
                            Spacer()
                            Text(getSumUp(for: record))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .background(
                            InstanceProgressBackground(
                                killedBosses: getNumberOfKilledBosses(for: record),
                                allBosses: getNumberOfEncounters(for: record),
                                faction: character.faction
                            )
                        )
                    }
                }
                .background(
                    InstanceProgressFullWidthBackgroundBlur()
                )
                
                    
            }
            .background(
                RaidTileBackground(raid: raid)
            )
            .frame(height: 240)
            .cornerRadius(15, antialiased: true)
            .padding(.horizontal, 15)
            .foregroundColor(.primary)
//        }
    }
    
    
    func filterModesForLegacyCompletion(in raid: CombinedRaidWithEncounters) -> [RaidEncountersForCharacter] {
        let helper = RaidDataHelper()
        
        // all raids after Mists of Pandaria (expansion.id = 74), excluding Siege of Orgrimmar (id=369)
        // were completed when it was just one mode Cleared
        // or in other words: you could only complete one raid mode per raid per week
        if raid.expansion.id <= 74 && raid.id != 369 {
            for raidMode in raid.records {
                if helper.isModeCleared(for: raidMode) {
                    return [raidMode]
                }
            }
        }
        
        return raid.records
        
    }
    
    
    func getSumUp(for mode: RaidEncountersForCharacter) -> String {
        let killedThisWeek = getNumberOfKilledBosses(for: mode)
        let allBosses = getNumberOfEncounters(for: mode)
        
        let sumUp = "\(killedThisWeek) / \(allBosses)"
        return sumUp
    }
    
    func getNumberOfEncounters(for mode: RaidEncountersForCharacter) -> Int {
        let expansionID = raid.expansion.id
        
        // the first two expansions (id 68 and 70) only have last boss in the player encounter, that's why we need a special legacy mode checker
        if expansionID < 72 {
            return 1
        } else {
            let numberOfEncounters = mode.progress.encounters.count
            return numberOfEncounters
        }
    }
    
    func getNumberOfKilledBosses(for mode: RaidEncountersForCharacter) -> Int {
        let expansionID = raid.expansion.id
        let helper = RaidDataHelper()
        
        var numberOfKilledBosses = 0
        
        // the first two expansions (id 68 and 70) only have last boss in the player encounter, that's why we need a special legacy mode checker
        if expansionID < 72 {
            numberOfKilledBosses = helper.isLegacyModeCleared(for: mode) ? 1 : 0
        } else {
            numberOfKilledBosses = helper.getNumberOfKilledBosses(for: mode)
        }
        return numberOfKilledBosses
    }
    
}

//struct RaidTile_Previews: PreviewProvider {
//    static var previews: some View {
//        CharacterRaidTile()
//    }
//}
