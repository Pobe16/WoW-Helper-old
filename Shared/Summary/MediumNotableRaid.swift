//
//  MediumNotableRaid.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct MediumNotableRaid: View {
    let namespace: Namespace.ID
    
    let character: RaidsSuggestedForCharacter
    
    let raid: RaidSuggestion
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                StoredCharacterImage(avatarData: CoreDataImagesManager.shared.getImage(using: character.characterAvatarURI), faction: character.characterFaction)
                    .padding()
                    .matchedGeometryEffect(id: "characterImage", in: namespace)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Text("\(raid.raidName)")
                    .lineLimit(2)
                    .font(.body)
                    .minimumScaleFactor(0.5)
                    .whiteTextWithBlackOutlineStyle()
                    .padding(.bottom)
                    .padding(.horizontal)
                    .matchedGeometryEffect(id: "raidName", in: namespace)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing){
                if (raid.items.count) == 0 {
                    EmptyView()
                } else {
                    MediumNotableLoot(namespace: namespace, items: raid.items)
                }
            }
        }
        .background(
            StoredRaidTileBackground(imageData: CoreDataImagesManager.shared.getImage(using:raid.raidImageURI))
                .matchedGeometryEffect(id: "backgroundTile", in: namespace)
        )
        .frame(width: 292, height: 141)
        .cornerRadius(25)
        .clipped()
        
    }
}
