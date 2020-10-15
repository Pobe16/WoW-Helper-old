//
//  MediumNotableRaid.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct MediumNotableRaid: View {
    let namespace: Namespace.ID
    
    let character: CharacterInProfile
    let raid: CombinedRaidWithEncounters
    
    @State var mounts: [MountItem]  = []
    @State var pets: [PetItem]      = []
    
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
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 40, height: 40)
                    .padding(.horizontal)
                    .padding(.top)
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 40, height: 40)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .background(
            RaidTileBackground(raid: raid)
        )
        .frame(width: 292, height: 141)
        .cornerRadius(25)
        .clipped()
    }
}
