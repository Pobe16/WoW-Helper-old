//
//  SummaryMain.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 05/10/2020.
//

import SwiftUI

struct SummaryMain: View {
    @EnvironmentObject var farmOrder: FarmCollectionsOrder
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    var body: some View {
        if gameData.loadingAllowed {
            
        } else {
            ScrollView{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Loading data…")
                Text("\(gameData.characters.count) characters")
                Text("\(gameData.expansions.count) expansions")
                Text("\(gameData.raids.count) raids")
                Text("\(gameData.raidEncounters.count) raid encounters")
                Text("\(gameData.characterRaidEncounters.count) additional character data")
                
            }
        }
    }
}

struct SummaryMain_Previews: PreviewProvider {
    static var previews: some View {
        SummaryMain()
    }
}
