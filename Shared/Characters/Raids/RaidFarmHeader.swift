//
//  RaidFarmHeader.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct RaidFarmHeader: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    let headerText: String
    let faction: Faction
    
    var body: some View {
        HStack{
            Text(headerText)
                .font(.title)
                .padding()
                .padding(.leading, 10)
                .whiteTextWithBlackOutlineStyle()
            Spacer()
        }
        .background(
            ZStack{
                Color("faction\(faction.type.rawValue)")
                Image(AdditionalTexturesNames.woodDamageV2.rawValue)
                .resizable(resizingMode: .tile)
            }
            .brightness(colorScheme == .dark ? 0.0 : 0.125)
        )
    }
}

struct RaidFarmHeader_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
            RaidFarmHeader(headerText: "Completed raids.", faction: Faction(type: .alliance, name: "Alliance"))
        }
        .previewLayout(.fixed(width: 500, height: 200))
        
        ZStack {
            Color.green
            RaidFarmHeader(headerText: "Completed raids.", faction: Faction(type: .alliance, name: "Alliance"))
        }
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
