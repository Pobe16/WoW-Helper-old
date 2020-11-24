//
//  NoRaidsLeftWidget.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import SwiftUI

struct NoRaidsLeftWidget: View {
    @Environment(\.widgetFamily) var family
    let container: RaidsSuggestedForCharacter
    let message: String
    
    var body: some View {
        
        switch family {
        case .systemLarge:
            VStack{
                HStack(alignment: .top) {
                    StoredCharacterImageWidget(avatarData: CoreDataImagesManager.shared.getImage(using:container.characterAvatarURI), faction: container.characterFaction)
                        .padding()
                    Spacer(minLength: 0)
                    Text("\(container.characterName), \(container.characterLevel)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.5)
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text(message)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .minimumScaleFactor(0.9)
                    Spacer(minLength: 0)
                }
                .padding()
            }
            .background(
                Image("Goldshire_Inn")
                    .resizable()
                    .scaledToFill()
            )
            
        case .systemMedium:
            VStack{
                HStack(alignment: .top) {
                    StoredCharacterImageWidget(avatarData: CoreDataImagesManager.shared.getImage(using:container.characterAvatarURI), faction: container.characterFaction)
                        .padding()
                    Spacer(minLength: 0)
                    Text("\(container.characterName), \(container.characterLevel)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.9)
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text(message)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .minimumScaleFactor(0.9)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(
                Image("Goldshire_Inn")
                    .resizable()
                    .scaledToFill()
            )
            
        case .systemSmall:
            VStack{
                HStack {
                    StoredCharacterImageWidget(avatarData: CoreDataImagesManager.shared.getImage(using: container.characterAvatarURI), faction: container.characterFaction, frameSize: 50)
                        .padding()
                    Spacer()
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text(message)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.5)
                    Spacer(minLength: 0)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .background(
                Image("Goldshire_Inn_Mini")
                    .resizable()
                    .scaledToFill()
            )
        @unknown default:
            Text(message)
        }
    }
}
