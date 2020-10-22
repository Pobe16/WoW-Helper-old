//
//  MediumNotableRaid.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct MediumNotableRaid: View {
    let namespace: Namespace.ID
    
    let character: CharacterInProfile
    let raid: CombinedRaidWithEncounters
    
    let items: [QualityItemStub]
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                CharacterImage(character: character)
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
                if (items.count) == 0 {
                    EmptyView()
                } else {
                    MediumNotableLoot(namespace: namespace, items: items)
                }
            }
        }
        .background(
            RaidTileBackground(raid: raid)
                .matchedGeometryEffect(id: "backgroundTile", in: namespace)
        )
        .frame(width: 292, height: 141)
        .cornerRadius(25)
        .clipped()
        
    }
}
