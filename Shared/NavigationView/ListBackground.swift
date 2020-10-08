//
//  ListBackground.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 24/09/2020.
//

import SwiftUI

struct ListBackground: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        ZStack{
            Image("Wooden_Flooring_F_02")
                .resizable(resizingMode: .tile)
            Image("Wood_Damage_Overlay_C_01")
                .resizable(resizingMode: .tile)
            
            HStack{
                Image("wall_leading")
                    .resizable(resizingMode: .tile)
                    .frame(minWidth: 0, maxWidth: 23)
                Spacer()
                    .frame(minWidth: 0, maxWidth: .infinity)
                Image("wall_trailing")
                    .resizable(resizingMode: .tile)
                    .frame(minWidth: 0, maxWidth: 23)
            }
            
            if colorScheme == .dark {
                Color.black.opacity(0.5)
            }
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

struct ListBackground_Previews: PreviewProvider {
    static var previews: some View {
        ListBackground()
            .previewLayout(.fixed(width: 800, height: 800))
    }
}
