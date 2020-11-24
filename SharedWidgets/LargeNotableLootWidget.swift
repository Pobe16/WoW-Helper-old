//
//  LargeNotableLootWidget.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import SwiftUI

struct LargeNotableLootWidget: View {
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
                    .clipShape(ContainerRelativeShape())
                    .overlay(
                        ContainerRelativeShape()
                            .strokeBorder(Color("quality_\(items[0].quality.rawValue)"), lineWidth: 1)
                    )
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
                        .clipShape(ContainerRelativeShape())
                        .overlay(
                            ContainerRelativeShape()
                                .strokeBorder(Color("quality_\(items[1].quality.rawValue)"), lineWidth: 1)
                        )
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
                        .clipShape(ContainerRelativeShape())
                        .overlay(
                            ContainerRelativeShape()
                                .strokeBorder(Color("quality_\(items[2].quality.rawValue)"), lineWidth: 1)
                        )
                }
            } else {
                Spacer()
            }
        }
        .padding()
    }
}
