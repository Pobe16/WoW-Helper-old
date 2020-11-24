//
//  SmallNotableRaid.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct SmallNotableRaid: View {
    let namespace: Namespace.ID
    
    let character: RaidsSuggestedForCharacter
    
    let raid: RaidSuggestion
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                StoredCharacterImage(avatarData: CoreDataImagesManager.shared.getImage(using: character.characterAvatarURI), faction: character.characterFaction, frameSize: 50)
                    .padding()
                    .matchedGeometryEffect(id: "characterImage", in: namespace)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
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
        .background(
            StoredRaidTileBackground(imageData: CoreDataImagesManager.shared.getImage(using:raid.raidImageURI))
                .matchedGeometryEffect(id: "backgroundTile", in: namespace)
        )
        .frame(width: 141, height: 141)
        .cornerRadius(25)
        .clipped()
    }
}
