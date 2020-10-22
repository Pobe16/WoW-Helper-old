//
//  DefaultListItemBackground.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 25/09/2020.
//

import SwiftUI

struct DefaultListItemBackground: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    let color: Color
    
    let selected: Bool
    
    #if os(iOS)
    let backgroundColor = UIColor.secondarySystemBackground
    #elseif os(macOS)
    let backgroundColor = NSColor.windowBackgroundColor
    #endif
    
    var body: some View {
        
        VStack(spacing: 0) {
            Color.clear
                .frame(height: 0.5)
            ZStack{
                Color(backgroundColor)
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(
                                color: Color("DefaultListItemColour")
                                    .opacity(selected ? 1 : 0.65),
                                location: 0
                            ),
                            .init(
                                color: color
                                    .opacity(selected ? 0.8 : 0.5),
                                location: 0.20
                            ),
                            .init(
                                color: color
                                    .opacity(selected ? 0.7 : 0.4),
                                location: 0.50
                            ),
                            .init(
                                color: Color("DefaultListItemColour")
                                    .opacity(selected ? 1 : colorScheme == .dark ? 0.65 : 0.25),
                                location: 1
                            )
                        ]),
                    startPoint: .leading,
                    endPoint: .trailing)
                Image("Wood_Damage_Overlay_B_01")
                    .resizable(resizingMode: .tile)
            }
            Color.clear
                .frame(height: 0.5)
        }
    }
}

struct DefaultListItemBackground_Previews: PreviewProvider {
    static var previews: some View {
        DefaultListItemBackground(color: Color.yellow, selected: true)
            .previewLayout(.fixed(width: 300, height: 80))
        
        
        DefaultListItemBackground(color: Color.yellow, selected: false)
            .previewLayout(.fixed(width: 300, height: 80))
            
    
        DefaultListItemBackground(color: Color.yellow, selected: true)
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .dark)
        
        
        DefaultListItemBackground(color: Color.yellow, selected: false)
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .dark)
    }
}
