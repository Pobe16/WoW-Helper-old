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
                    SingleCharacterSummary(
                        character: getCharacterBasedOn(encounters: GDCharacterEncounters),
                        characterEncounters: GDCharacterEncounters
                    )
                }
            }
//            .edgesIgnoringSafeArea(.all)
            .background(ListBackground())
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    Text("Farming opportunities:")
                        .font(.title2)
                }
            })
        } else {
            DataLoadingInfo()
                .background(ListBackground())
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        Text("Loading game data…")
                            .font(.title3)
                    }
                })
        }
        
    }
    
    func getCharacterBasedOn(encounters: CharacterRaidEncounters) -> CharacterInProfile {
        let character = gameData.characters.first { (GDCharacter) -> Bool in
            GDCharacter.name == encounters.character.name && GDCharacter.realm.name == encounters.character.realm.name
        }
        return character!
    }
}


