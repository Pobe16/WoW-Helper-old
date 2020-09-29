//
//  ExpansionGameDataPreview.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 23/08/2020.
//

import SwiftUI

struct ExpansionGameDataPreview: View {
    @EnvironmentObject var gameData: GameData
    @State var expansion: ExpansionJournal
    
    var body: some View {
        VStack(alignment: .leading){
            Text(expansion.name)
                .font(.largeTitle)
                .padding(.leading)
            
            Text("Raids")
                .font(.title)
                .padding([.leading, .top])
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    if gameData.raids.filter{$0.expansion.id == expansion.id }.count > 0 {
                        ForEach(gameData.raids.filter{ $0.expansion.id == expansion.id }){ raid in
                            InstanceTile(instance: raid, category: raid.category.type.rawValue.lowercased())
                                .padding()
                        }
                    } else {
                        InstanceTile(category: InstanceCategoryType.raid.rawValue.lowercased())
                            .padding()
                    }
                }
            }
            Text("Dungeons")
                .font(.title)
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    if gameData.dungeons.filter{$0.expansion.id == expansion.id }.count > 0 {
                        ForEach(gameData.dungeons.filter{ $0.expansion.id == expansion.id }){ dungeon in
                            InstanceTile(instance: dungeon, category: dungeon.category.type.rawValue.lowercased())
                                .padding()
                        }
                    } else {
                        InstanceTile(category: InstanceCategoryType.dungeon.rawValue.lowercased())
                            .padding()
                    }
                    
                }
            }
            
        }
        .padding(.bottom)
    }
}
