//
//  StoredCharacterImageWidget.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import SwiftUI

struct StoredCharacterImageWidget: View {
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
                .clipShape(ContainerRelativeShape())
                .overlay(
                    ContainerRelativeShape()
                        .strokeBorder(Color("faction\(faction.rawValue)"), lineWidth: 2)
                )
            
        } else {
            #if os(iOS)
            Image(uiImage: UIImage(data: avatarData!)!)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .clipShape(ContainerRelativeShape())
                .overlay(
                    ContainerRelativeShape()
                        .strokeBorder(Color("faction\(faction.rawValue)"), lineWidth: 2)
                )
            #else
            Image(nsImage: NSImage(data: avatarData!)!)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .clipShape(ContainerRelativeShape())
                .overlay(
                    ContainerRelativeShape()
                        .strokeBorder(Color("faction\(faction.rawValue)"), lineWidth: 2)
                )
            #endif
        }
    }
}
