//
//  WhiteTextWithBlackOutline.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 11/10/2020.
//

import SwiftUI

struct WhiteTextWithBlackOutline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
//            .shadow(color: .black, radius: 3)
            .shadow(color: .black, radius: 2)
            .shadow(color: .black, radius: 1)
    }
}

extension View {
    func whiteTextWithBlackOutlineStyle() -> some View {
        self.modifier(WhiteTextWithBlackOutline())
    }
}

