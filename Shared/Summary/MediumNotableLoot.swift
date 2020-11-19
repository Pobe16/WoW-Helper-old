//
//  MediumNotableLoot.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct MediumNotableLoot: View {
    let namespace: Namespace.ID
    
    let items: [RaidSuggestionItem]
    
    var body: some View {
        VStack{
            StoredItemIcon(icon: CoreDataImagesManager.shared.getImage(using: items[0].iconURI))
                .frame(width: 45, height: 45)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color("quality_\(items[0].quality.rawValue)"), lineWidth: 1)
                )
                .matchedGeometryEffect(id: "firstLoot", in: namespace)
            Spacer(minLength: 0)
            
            if items.count > 1 {
                StoredItemIcon(icon: CoreDataImagesManager.shared.getImage(using: items[1].iconURI))
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color("quality_\(items[1].quality.rawValue)"), lineWidth: 1)
                    )
                    .matchedGeometryEffect(id: "secondLoot", in: namespace)
            }
        }
        .padding(.trailing)
        .padding(.vertical)
    }
}
