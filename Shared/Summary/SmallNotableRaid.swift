//
//  SmallNotableRaid.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct SmallNotableRaid: View {
    let namespace: Namespace.ID
    
    let character: CharacterInProfile
    let raid: CombinedRaidWithEncounters
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CharacterImage(character: character, frameSize: 50)
                    .padding()
                    .matchedGeometryEffect(id: "characterImage", in: namespace)
                Spacer()
            }
            Spacer(minLength: 0)
            Text(raid.raidName)
                .whiteTextWithBlackOutlineStyle()
                .minimumScaleFactor(0.8)
                .padding()
                .matchedGeometryEffect(id: "raidName", in: namespace)
            
            
        }
        .background(
            RaidTileBackground(name: raid.raidName, id: raid.raidId, mediaUrl: raid.media.key.href)
        )
        .frame(width: 141, height: 141)
        .cornerRadius(25)
        .clipped()
    }
}
