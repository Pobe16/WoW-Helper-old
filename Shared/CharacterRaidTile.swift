//
//  CharacterRaidTile.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI
import VisualEffects

struct CharacterRaidTile: View {
    let raid: CombinedRaidWithEncounters
    let faction: Faction
    
    var body: some View {
        
        
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
            .background(VisualEffectBlur(blurStyle: .systemChromeMaterial))
            
            Spacer()
            VStack {
                ForEach(raid.records, id: \.self){ record in
                    HStack {
                        Text("\(record.difficulty.name)")
                        Spacer()
                        Text(getSumUp(for: record))
                    }
                    .padding(.bottom, 0)
                    .padding(.horizontal, 10)
                    .background(
                        InstanceProgressBackground(
                            killedBosses: getNumberOfKilledBosses(for: record),
                            allBosses: getNumberOfEncounters(for: record),
                            faction: faction
                        )
                    )
                }
            }
            .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterial).opacity(0.75))
            
                
        }
        .background(
            RaidTileBackground(name: raid.raidName, id: raid.raidId, mediaUrl: raid.media.key.href)
        )
        .frame(height: 220)
        .cornerRadius(15, antialiased: true)
        .padding(.horizontal, 15)
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
