//
//  StoredItemIcon.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 18/11/2020.
//

import SwiftUI

struct StoredItemIcon: View {
    let icon: Data?
    
    var body: some View {
        
        if icon == nil {
            
            Image("item_placeholder")
                .resizable()
                .scaledToFit()
            
        } else {
            
            #if os(iOS)
            Image(uiImage: UIImage(data: icon!)!)
                .resizable()
                .scaledToFit()
            #else
            Image(nsImage: NSImage(data: icon!)!)
                .resizable()
                .scaledToFit()
            #endif
            
        }
    }
}

struct StoredItemIcon_Previews: PreviewProvider {
    static var previews: some View {
        StoredItemIcon(icon: nil)
    }
}
