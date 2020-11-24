//
//  SmallNotableRaidWidget.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import SwiftUI

struct SmallNotableRaidWidget: View {
    let container: RaidsSuggestedForCharacter
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                StoredCharacterImageWidget(avatarData: CoreDataImagesManager.shared.getImage(using: container.characterAvatarURI), faction: container.characterFaction, frameSize: 50)
                    .padding()
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            Spacer(minLength: 0)
            Text("\(container.raids.first!.raidName)")
                .lineLimit(2)
                .font(.body)
                .minimumScaleFactor(0.5)
                .whiteTextWithBlackOutlineStyle()
                .padding(.bottom)
                .padding(.horizontal)
            
            
        }
        .background(
            StoredRaidTileBackground(imageData: CoreDataImagesManager.shared.getImage(using: container.raids.first!.raidImageURI))
        )
    }
}

