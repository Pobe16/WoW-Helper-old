//
//  SmallNotableRaid.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct SmallNotableRaid: View {
    @EnvironmentObject var gameData: GameData
    let namespace: Namespace.ID
    
    let character: CharacterInProfile
    let raid: CombinedRaidWithEncounters
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CharacterImage(character: character, frameSize: 50)
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
            RaidTileBackground(raid: raid)
                .matchedGeometryEffect(id: "backgroundTile", in: namespace)
        )
        .frame(width: 141, height: 141)
        .cornerRadius(25)
        .clipped()
    }
}
