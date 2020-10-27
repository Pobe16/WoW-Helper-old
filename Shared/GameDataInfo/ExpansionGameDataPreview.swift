//
//  ExpansionGameDataPreview.swift
//  WoWHelper 
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
                .whiteTextWithBlackOutlineStyle()
                .padding([.leading, .top])
                .padding(.horizontal)
            
            Text("Raids")
                .font(.title)
                .whiteTextWithBlackOutlineStyle()
                .padding([.leading, .top])
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    if gameData.raids.filter{$0.expansion.id == expansion.id }.count > 0 {
                        ForEach(gameData.raids.filter{ $0.expansion.id == expansion.id }){ raid in
                            InstanceTile(instance: raid, category: raid.category.type.rawValue.lowercased())
                                .padding()
                        }
                    } else {
                        InstancePlaceholderTile(category: InstanceCategoryType.raid.rawValue.lowercased())
                            .padding()
                        Spacer()
                    }
                }
                .padding()
                .background(
                    BackgroundTexture(texture: .moss, wall: .all)
                        .edgesIgnoringSafeArea(.all)
                )
            }
            .background(
                BackgroundTexture(texture: .wood, wall: .all)
                    .edgesIgnoringSafeArea(.all)
            )
            
        }
        .padding(.bottom)
        .padding(.bottom)
    }
}
