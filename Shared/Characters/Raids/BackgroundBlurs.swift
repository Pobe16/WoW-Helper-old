//
//  BackgroundBlurs.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 04/09/2020.
//

import SwiftUI
import VisualEffects

struct RaidTitleBackgroundBlur: View {
    var body: some View {
        #if os(iOS)
        VisualEffectBlur(blurStyle: .systemChromeMaterial)
        #elseif os(macOS)
        VisualEffectBlur(
            material: .headerView,
            blendingMode: .withinWindow,
            state: .followsWindowActiveState
        )
        #endif
    }
}

struct InstanceProgressFullWidthBackgroundBlur: View {
    
    var blurOpacity: Double = 0.85
    
    var body: some View {
        #if os(iOS)
        VisualEffectBlur(blurStyle: .systemUltraThinMaterial).opacity(blurOpacity)
        #elseif os(macOS)
        VisualEffectBlur(
            material: .contentBackground,
            blendingMode: .withinWindow,
            state: .followsWindowActiveState
        ).opacity(blurOpacity)
        #endif
    }
}

struct InstanceProgressBackground: View {
    let killedBosses: Int
    let allBosses: Int
    let faction: Faction
    
    var body: some View {
        GeometryReader { geometry in

            Color("faction\(faction.type.rawValue)")
                .frame(
                    width:
                        geometry.size.width /
                        CGFloat(allBosses) *
                        CGFloat(killedBosses)
                )
                .opacity(0.5)
            Spacer()
        }
    }
}



struct BackgroundBlurs_Previews: PreviewProvider {
    static var previews: some View {
        RaidTitleBackgroundBlur()
            .previewLayout(.fixed(width: 300, height: 100))
        InstanceProgressFullWidthBackgroundBlur()
            .previewLayout(.fixed(width: 300, height: 100))
        InstanceProgressBackground(killedBosses: 3, allBosses: 5, faction: Faction(type: .alliance, name: "Alliance"))
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
