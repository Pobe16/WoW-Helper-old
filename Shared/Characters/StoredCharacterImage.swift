//
//  StoredCharacterImage.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 18/11/2020.
//

import SwiftUI

struct StoredCharacterImage: View {
    let avatarData: Data?
    let faction: FactionType
    @State var frameSize: CGFloat = 63
    let placeholder = "avatar_placeholder"
    
    var body: some View {
        if avatarData == nil {
            
            Image(placeholder)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .cornerRadius(15, antialiased: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color("faction\(faction.rawValue)"), lineWidth: 2)
                )
            
        } else {
            #if os(iOS)
            Image(uiImage: UIImage(data: avatarData!)!)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .cornerRadius(15, antialiased: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color("faction\(faction.rawValue)"), lineWidth: 2)
                )
            #else
            Image(nsImage: NSImage(data: avatarData!)!)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .cornerRadius(15, antialiased: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color("faction\(faction.rawValue)"), lineWidth: 2)
                )
            #endif
        }
    }
    
}

struct StoredCharacterImage_Previews: PreviewProvider {
    static var previews: some View {
        StoredCharacterImage(avatarData: nil, faction: .alliance)
    }
}
