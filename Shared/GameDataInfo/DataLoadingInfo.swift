//
//  DataLoadingInfo.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 06/10/2020.
//

import SwiftUI

struct DataLoadingInfo: View {
    @EnvironmentObject var gameData: GameData
    var body: some View {
        ScrollView{
            HStack{
                VStack(alignment: .leading){
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading data…")
                        .font(.title)
                    Text("\(gameData.characters.count) character\(gameData.characters.count == 1 ? "" : "s")")
                    Text("\(gameData.expansions.count) expansions")
                    Text("\(gameData.raids.count) raids")
                    Text("\(gameData.raidEncounters.count) raid encounters")
                    Text("\(gameData.characterRaidEncounters.count) additional character data")
                }
                .padding()
                .font(.title)
                Spacer()
            }
            .padding()
            
        }
        .background(BackgroundTexture(texture: .flagstone, wall: .horizontal))
        
    }
}
