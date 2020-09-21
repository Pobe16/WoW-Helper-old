//
//  RaidDetails.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 20/09/2020.
//

import SwiftUI

struct RaidDetails: View {
    @Namespace var tile
    
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    
    let columns = [
        GridItem(.adaptive(minimum: 340), spacing: 20)
    ]
    
    let raid: CombinedRaidWithEncounters
    let character: CharacterInProfile
    
    var body: some View {
        GeometryReader { geometry in
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    Section {
                        RaidTileBackground(name: raid.raidName, id: raid.raidId, mediaUrl: raid.media.key.href)
                            .frame(minWidth: 0, maxWidth: 500)
                        
                        if raid.description != nil && geometry.size.width > 600 {
                            Text(raid.description!)
                                .padding()
                        } else {
                            VStack {
                                Spacer()
                                Text("Minimum level: \(raid.minimumLevel)")
                                Spacer()
                                Text("Part of raids in \(raid.expansion.name)")
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    
                    
                    
                    ForEach(selectHighestMode(modes: raid.records), id: \.self){ raidMode in
                        Section(header: Text(raidMode.difficulty.name)) {
                            VStack{
                                Text(raidMode.status.name)
                                Text("Times started: \(raidMode.progress.totalCount)")
                                Text("Times completed: \(raidMode.progress.completedCount)")
                            }
                            .padding()
                            ForEach(raidMode.progress.encounters, id: \.self) { encounter in
                                VStack{
                                    Text("\(encounter.encounter.name)")
                                    Text("Times killed: \(encounter.completedCount)")
                                    if encounter.lastKillTimestamp != nil {
                                    Text("Last killed: \(encounter.lastKillTimestamp!)")
                                    }
                                }
                                .padding()
                            }
                        }
                        
                    }
                    Section{
                        if raid.description != nil && geometry.size.width < 600 {
                            Text(raid.description!)
                        }  else {
                            VStack {
                                Text("Minimum level: \(raid.minimumLevel)")
                                Spacer()
                                Text("Part of raids in \(raid.expansion.name)")
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(raid.raidName)")
                }
            }
            
        }
    }
    
    func selectHighestMode(modes: [RaidEncountersForCharacter]) -> [RaidEncountersForCharacter] {
        return [modes.last!]
    }
    
}
