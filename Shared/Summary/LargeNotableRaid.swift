//
//  LargeNotableRaid.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 16/10/2020.
//

import SwiftUI

struct LargeNotableRaid: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    let namespace: Namespace.ID
    
    let character: RaidsSuggestedForCharacter
    
    let raid: RaidSuggestion
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    StoredCharacterImage(avatarData: CoreDataImagesManager.shared.getImage(using: character.characterAvatarURI), faction: character.characterFaction)
                        .padding()
                        .matchedGeometryEffect(id: "characterImage", in: namespace)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    Text("\(character.characterName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.5)
                        .matchedGeometryEffect(id: "characterName", in: namespace)
                }
                Spacer(minLength: 0)
                Text("\(raid.raidName)")
                    .lineLimit(1)
                    .font(.title2)
                    .minimumScaleFactor(0.8)
                    .whiteTextWithBlackOutlineStyle()
                    .padding(.bottom)
                    .padding(.horizontal)
                    .matchedGeometryEffect(id: "raidName", in: namespace)
            }
            
            if raid.items.count > 0 {
                LargeNotableLoot(namespace: namespace, items: raid.items)
                    .background(
                        DarkOrBrightTransparentBackground()
                    )
            }
            
        }.background(
            StoredRaidTileBackground(imageData: CoreDataImagesManager.shared.getImage(using:raid.raidImageURI))
                .matchedGeometryEffect(id: "backgroundTile", in: namespace)
        )
        .frame(width: 292, height: 311)
        .cornerRadius(25)
        .clipped()
        
    }
    
}
