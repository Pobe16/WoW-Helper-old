//
//  StoredRaidTileBackground.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 18/11/2020.
//

import SwiftUI

struct StoredRaidTileBackground: View {
    
    let imageData: Data?
    
    var body: some View {
        if imageData == nil {
            Image("raid_placeholder")
                .resizable()
                .scaledToFill()
        } else {
            #if os(iOS)
            Image(uiImage: UIImage(data: imageData!)!)
                .resizable()
                .scaledToFill()
            #elseif os(macOS)
            Image(nsImage: NSImage(data: imageData!)!)
                .resizable()
                .scaledToFill()
            #endif
        }
    }
    
}

struct StoredRaidTileBackground_Previews: PreviewProvider {
    static var previews: some View {
        StoredRaidTileBackground(imageData: nil)
    }
}
