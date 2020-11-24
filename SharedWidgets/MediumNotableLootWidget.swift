//
//  MediumNotableLootWidget.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import SwiftUI

struct MediumNotableLootWidget: View {
    let items: [RaidSuggestionItem]
    
    var body: some View {
        VStack{
            StoredItemIcon(icon: CoreDataImagesManager.shared.getImage(using: items[0].iconURI))
                .frame(width: 45, height: 45)
                .cornerRadius(10)
                .clipShape(ContainerRelativeShape())
                .overlay(
                    ContainerRelativeShape()
                        .strokeBorder(Color("quality_\(items[0].quality.rawValue)"), lineWidth: 1)
                )
            Spacer(minLength: 0)
            
            if items.count > 1 {
                StoredItemIcon(icon: CoreDataImagesManager.shared.getImage(using: items[1].iconURI))
                    .frame(width: 45, height: 45)
                    .clipShape(ContainerRelativeShape())
                    .overlay(
                        ContainerRelativeShape()
                            .strokeBorder(Color("quality_\(items[1].quality.rawValue)"), lineWidth: 1)
                    )
            }
        }
        .padding(.trailing)
        .padding(.vertical)
    }
}
