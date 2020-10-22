//
//  BackgroundStoneTexture.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 11/10/2020.
//

import SwiftUI

enum availableBackgroundTextures: String {
    case flagstone  = "Large_Flagstone"
    case wood       = "Wooden_Flooring"
    case wood2      = "Wooden_Flooring2"
    case brick      = "Brick_Floor"
    case moss       = "mossy_rock"
    case ice        = "ice"
    case arches     = "Cobblestone_Arches"
}

enum additionalTexturesNames: String {
    case wallLeading    = "wall_leading"
    case wallTrailing   = "wall_trailing"
    case woodDamageV1   = "Wood_Damage_Overlay_C_01"
    case woodDamageV2   = "Wood_Damage_Overlay_B_01"
    case wallTop        = "wall_top"
    
}

enum wallPosition {
    case none
    case all
    case horizontal
    case vertical
    case leading
    case trailing
    case top
    case bottom
}

struct BackgroundTexture: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    let texture: availableBackgroundTextures
    let wall: wallPosition
    
    
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
                if texture == .flagstone || texture == .ice {
                    Color.white.opacity(0.5)
                }
            }
            
            BackgroundWall(wall: wall)
            
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}


struct BackgroundWall: View {
    let wall: wallPosition
    var body: some View{
        
        switch wall {
        case .none:
            EmptyView()
            
        case .all:
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
            VStack{
                Image(additionalTexturesNames.wallTop.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minHeight: 0, maxHeight: 15)
                Spacer()
                    .frame(minHeight: 0, maxHeight: .infinity)
                Image(additionalTexturesNames.wallTop.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minHeight: 0, maxHeight: 15)
                    .rotationEffect(Angle(degrees: 180))
            }
        case .horizontal:
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
            
        case .vertical:
            VStack{
                Image(additionalTexturesNames.wallTop.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minHeight: 0, maxHeight: 15)
                Spacer()
                    .frame(minHeight: 0, maxHeight: .infinity)
                Image(additionalTexturesNames.wallTop.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minHeight: 0, maxHeight: 15)
                    .rotationEffect(Angle(degrees: 180))
            }
            
        case .leading:
            HStack{
                Image(additionalTexturesNames.wallLeading.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minWidth: 0, maxWidth: 23)
                Spacer()
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            
        case .trailing:
            HStack{
                Spacer()
                    .frame(minWidth: 0, maxWidth: .infinity)
                Image(additionalTexturesNames.wallTrailing.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minWidth: 0, maxWidth: 23)
            }
            
        case .top:
            VStack{
                Image(additionalTexturesNames.wallTop.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minHeight: 0, maxHeight: 15)
                Spacer()
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
            
        case .bottom:
            VStack{
                Spacer()
                    .frame(minHeight: 0, maxHeight: .infinity)
                Image(additionalTexturesNames.wallTop.rawValue)
                    .resizable(resizingMode: .tile)
                    .frame(minHeight: 0, maxHeight: 15)
                    .rotationEffect(Angle(degrees: 180))
            }
            
        }
    }
}


struct BackgroundTexture_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            BackgroundTexture(texture: .flagstone, wall: .vertical)
            Text("Hello World!")
        }
            .previewLayout(.fixed(width: 800, height: 800))
    }
}

