//
//  NavListSectionHeader.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 24/09/2020.
//

import SwiftUI

struct NavListSectionHeader: View {
    let text: String
    
    #if os(iOS)
    let backgroundColor = UIColor.secondarySystemBackground
    #elseif os(macOS)
    let backgroundColor = NSColor.windowBackgroundColor
    #endif
    
    var body: some View {
        HStack {
            Text(text)
                .fontWeight(.heavy)
                .foregroundColor(.white)
//                .padding()
            Spacer()
        }
//        .background(
//            Image("Acid_A_03")
//                .resizable(resizingMode: .tile)
//        )
//        .cornerRadius(15)
    }
}

struct NavListSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavListSectionHeader(text: "Test")
    }
}
