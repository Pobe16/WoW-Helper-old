//
//  BackgroundBlurs.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 04/09/2020.
//

import SwiftUI
import VisualEffects

struct DarkOrBrightTransparentBackground: View {
    
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        if colorScheme == .dark {
            Color.black.opacity(0.5)
        } else {
            Color.white.opacity(0.5)
        }
    }
}

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
                        CGFloat(killedBosses) + geometry.size.height
                )
                .opacity(0.5)
                .overlay(
                    RoundedRectangle(cornerRadius: geometry.size.height/2)
                        .stroke(
                            Color("faction\(faction.type.rawValue)"),
                            lineWidth: 1
                        )
                        .opacity(0.75)
                )
                .clipShape(Capsule())
                .offset(x: -geometry.size.height / (0 < killedBosses ? 2 : 1))
                
            Spacer()
        }
    }
    
}



struct BackgroundBlurs_Previews: PreviewProvider {
    static var previews: some View {
        RaidTitleBackgroundBlur()
            .previewLayout(.fixed(width: 300, height: 30))
        InstanceProgressFullWidthBackgroundBlur()
            .previewLayout(.fixed(width: 300, height: 30))
        InstanceProgressBackground(killedBosses: 3, allBosses: 10, faction: Faction(type: .alliance, name: "Alliance"))
            .previewLayout(.fixed(width: 300, height: 30))
    }
}
