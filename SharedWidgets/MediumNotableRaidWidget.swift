//
//  MediumNotableRaidWidget.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import SwiftUI

struct MediumNotableRaidWidget: View {
    
    let container: RaidsSuggestedForCharacter
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                StoredCharacterImageWidget(avatarData: CoreDataImagesManager.shared.getImage(using: container.characterAvatarURI), faction: container.characterFaction)
                    .padding()
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Text("\(container.raids.first!.raidName)")
                    .lineLimit(2)
                    .font(.body)
                    .minimumScaleFactor(0.5)
                    .whiteTextWithBlackOutlineStyle()
                    .padding(.bottom)
                    .padding(.horizontal)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing){
                if container.raids.first!.items.isEmpty {
                    EmptyView()
                } else {
                    MediumNotableLootWidget(items: container.raids.first!.items)
                }
            }
        }
        .background(
            StoredRaidTileBackground(imageData: CoreDataImagesManager.shared.getImage(using: container.raids.first!.raidImageURI))
        )
        
    }
}
