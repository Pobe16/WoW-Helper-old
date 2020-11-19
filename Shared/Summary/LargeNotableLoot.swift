//
//  LargeNotableLoot.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 16/10/2020.
//

import SwiftUI

struct LargeNotableLoot: View {
    let namespace: Namespace.ID
    
    let items: [RaidSuggestionItem]
    
    var body: some View {
        VStack{
            HStack() {
                Text("\(items[0].name)")
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .font(.body)
                    .minimumScaleFactor(0.5)
                Spacer()
                StoredItemIcon(icon: CoreDataImagesManager.shared.getImage(using: items[0].iconURI))
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color("quality_\(items[0].quality.rawValue)"), lineWidth: 1)
                    )
                    .matchedGeometryEffect(id: "firstLoot", in: namespace)
            }
            if items.count > 1 {
                HStack(alignment: .center) {
                    Text("\(items[1].name)")
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .font(.body)
                        .minimumScaleFactor(0.5)
                    Spacer(minLength: 0)
                    StoredItemIcon(icon: CoreDataImagesManager.shared.getImage(using: items[1].iconURI))
                        .frame(width: 32, height: 32)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color("quality_\(items[1].quality.rawValue)"), lineWidth: 1)
                        )
                        .matchedGeometryEffect(id: "secondLoot", in: namespace)
                }
            }
            if items.count > 2 {
                HStack() {
                    Text("\(items[2].name)")
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .font(.body)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    StoredItemIcon(icon: CoreDataImagesManager.shared.getImage(using: items[2].iconURI))
                        .frame(width: 32, height: 32)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color("quality_\(items[2].quality.rawValue)"), lineWidth: 1)
                        )
                        .matchedGeometryEffect(id: "thirdLoot", in: namespace)
                }
            } else {
                Spacer()
            }
        }
//        .padding(.top, 23)
        .padding()
    }
}

