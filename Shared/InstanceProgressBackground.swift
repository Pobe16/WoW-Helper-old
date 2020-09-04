//
//  InstanceProgressBackground.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 04/09/2020.
//

import SwiftUI

struct InstanceProgressBackground: View {
    let killedBosses: Int
    let allBosses: Int
    let faction: Faction
    
    var body: some View {
        GeometryReader { geometry in
            
            switch faction.type {
            case "ALLIANCE":
                HStack {
                    Color.blue.opacity(0.6)
                        .frame( width: geometry.size.width / CGFloat(allBosses) * CGFloat(killedBosses) )
                    Spacer()
                }
            case "HORDE":
                HStack {
                    Color.red.opacity(0.6)
                        .frame( width: geometry.size.width / CGFloat(allBosses) * CGFloat(killedBosses) )
                    Spacer()
                }
            default:
                HStack {
                    Color.white.opacity(0.3)
                        .frame( width: geometry.size.width / CGFloat(allBosses) * CGFloat(killedBosses) )
                    Spacer()
                }
            }
        }
    }
}

struct InstanceProgressBackground_Previews: PreviewProvider {
    static var previews: some View {
        InstanceProgressBackground(killedBosses: 3, allBosses: 5, faction: Faction(type: "ALLIANCE", name: "Alliance"))
    }
}
