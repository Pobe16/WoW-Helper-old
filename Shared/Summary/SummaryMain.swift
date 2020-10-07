//
//  SummaryMain.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 05/10/2020.
//

import SwiftUI

struct SummaryMain: View {
    @EnvironmentObject var gameData: GameData
    var body: some View {
        if gameData.loadingAllowed {
            ScrollView {
                ForEach(gameData.characterRaidEncounters, id: \.character.id) { GDCharacterEncounters in
                    SingleCharacterSummary(characterEncounters: GDCharacterEncounters)
                }
            }
        } else {
            DataLoadingInfo()
        }
    }
}


