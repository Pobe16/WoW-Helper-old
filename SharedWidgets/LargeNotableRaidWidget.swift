//
//  LargeNotableRaidWidget.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import SwiftUI

struct LargeNotableRaidWidget: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    let container: RaidsSuggestedForCharacter
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    StoredCharacterImageWidget(avatarData: CoreDataImagesManager.shared.getImage(using: container.characterAvatarURI), faction: container.characterFaction)
                        .padding()
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    Text("\(container.characterName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.5)
                }
                Spacer(minLength: 0)
                Text("\(container.raids.first!.raidName)")
                    .lineLimit(1)
                    .font(.title2)
                    .minimumScaleFactor(0.8)
                    .whiteTextWithBlackOutlineStyle()
                    .padding(.bottom)
                    .padding(.horizontal)
            }
            
            if !container.raids.first!.items.isEmpty {
                LargeNotableLootWidget(items: container.raids.first!.items)
                    .background(
                        DarkOrBrightTransparentBackground()
                    )
            }
            
        }.background(
            StoredRaidTileBackground(imageData: CoreDataImagesManager.shared.getImage(using: container.raids.first!.raidImageURI))
        )
        
    }
}
