//
//  LargeNotableRaid.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 16/10/2020.
//

import SwiftUI

struct LargeNotableRaid: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    let namespace: Namespace.ID
    
    let character: CharacterInProfile
    let raid: CombinedRaidWithEncounters
    
    let items: [QualityItemStub]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    CharacterImage(character: character)
                        .padding()
                        .matchedGeometryEffect(id: "characterImage", in: namespace)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    Text("\(character.name)")
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
            
            if items.count > 0 {
                LargeNotableLoot(namespace: namespace, items: items)
                    .background(
                        DarkOrBrightTransparentBackground()
                    )
            }
            
        }.background(
            RaidTileBackground(raid: raid)
                .matchedGeometryEffect(id: "backgroundTile", in: namespace)
        )
        .frame(width: 292, height: 311)
        .cornerRadius(25)
        .clipped()
        
    }
}
