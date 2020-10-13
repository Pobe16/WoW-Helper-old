//
//  BackgroundStoneTexture.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 11/10/2020.
//

import SwiftUI

enum availableBackgroundTextures: String {
    case flagstone  = "Large_Flagstone"
    case wood       = "Wooden_Flooring"
}

enum additionalTexturesNames: String {
    case wallLeading    = "wall_leading"
    case wallTrailing   = "wall_trailing"
    case woodDamageV1   = "Wood_Damage_Overlay_C_01"
    case woodDamageV2   = "Wood_Damage_Overlay_B_01"
}

struct BackgroundTexture: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    let texture: availableBackgroundTextures
    let wall: Bool
    
    var body: some View {
        ZStack{
            Image(texture.rawValue)
                .resizable(resizingMode: .tile)
            
            if texture == .wood {
                Image(additionalTexturesNames.woodDamageV1.rawValue)
                .resizable(resizingMode: .tile)
            }
            
            if colorScheme == .dark {
                Color.black.opacity(0.5)
            } else {
                if texture == .flagstone {
                    Color.white.opacity(0.5)
                }
            }
            
            
            if wall {
                HStack{
                    Image(additionalTexturesNames.wallLeading.rawValue)
                        .resizable(resizingMode: .tile)
                        .frame(minWidth: 0, maxWidth: 23)
                    Spacer()
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Image(additionalTexturesNames.wallTrailing.rawValue)
                        .resizable(resizingMode: .tile)
                        .frame(minWidth: 0, maxWidth: 23)
                }
            }
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

struct BackgroundTexture_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            BackgroundTexture(texture: .flagstone, wall: false)
            Text("Hello World!")
        }
            .previewLayout(.fixed(width: 800, height: 800))
    }
}

