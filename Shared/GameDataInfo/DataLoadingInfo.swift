//
//  DataLoadingInfo.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 06/10/2020.
//

import SwiftUI

struct DataLoadingInfo: View {
    @EnvironmentObject var gameData: GameData
    var body: some View {
        ScrollView{
            HStack{
                Spacer()
                VStack{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading data…")
                    Text("\(gameData.characters.count) characters")
                    Text("\(gameData.expansions.count) expansions")
                    Text("\(gameData.raids.count) raids")
                    Text("\(gameData.raidEncounters.count) raid encounters")
                    Text("\(gameData.characterRaidEncounters.count) additional character data")
                }
                Spacer()
            }
            
        }
        .background(BackgroundTexture(texture: .flagstone, wall: true))
        
    }
}
