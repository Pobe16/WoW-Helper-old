//
//  SingleCharacterSummary.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 06/10/2020.
//

import SwiftUI

struct SingleCharacterSummary: View {
    @EnvironmentObject var farmOrder: FarmCollectionsOrder
    @EnvironmentObject var gameData: GameData
    
    let summarySize: summaryPreviewSize
    let character: CharacterInProfile
    let raidSuggestions: RaidsSuggestedForCharacter?
    
    
    let message: String = "Loading…"
    
    var body: some View {
        HStack(spacing:0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(character.name) - \(character.realm.name)")
                    .font(.title2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.25)
                    .whiteTextWithBlackOutlineStyle()
                Text("\(character.level) - \(character.playableRace.name), \(character.playableClass.name)")
                    .whiteTextWithBlackOutlineStyle()
            }
            .padding()
            Spacer()
        }
        .background(
            CharacterListItemBackground(
                charClass: character.playableClass,
                faction: character.faction,
                selected: false
            )
        )
        .cornerRadius(5)
        .padding()
        if raidSuggestions != nil {
            
            if raidSuggestions!.raids.isEmpty {
                
                NoFarmingLeft(summarySize: summarySize, suggestion: raidSuggestions!)
                   .padding(.horizontal)
                
            } else {
                
                SummaryOfNotableRaids(summarySize: summarySize, suggestions: raidSuggestions!)
                
            }
            
        } else {
            
            Text(message)
                .padding()
        }
        
    }
}


