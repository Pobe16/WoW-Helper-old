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
                .whiteTextWithBlackOutlineStyle()
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct NavListSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavListSectionHeader(text: "Test")
    }
}
