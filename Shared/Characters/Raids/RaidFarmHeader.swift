//
//  RaidFarmHeader.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI
import VisualEffects

struct RaidFarmHeader: View {
    
    let headerText: String
    let faction: Faction
    
    var body: some View {
        HStack{
            Text(headerText)
                .font(.title)
                .padding()
                .padding(.leading, 10)
            Spacer()
        }
        .background(
            ZStack{
//                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                switch faction.type {
                case .alliance:
                    Color.blue.opacity(0.45)
                case .horde:
                    Color.red.opacity(0.45)
                default:
                    Color.white.opacity(0.45)
                }
            }
        )
    }
}

struct RaidFarmHeader_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
            RaidFarmHeader(headerText: "Completed raids.", faction: Faction(type: .alliance, name: "Alliance"))
        }
    }
}
