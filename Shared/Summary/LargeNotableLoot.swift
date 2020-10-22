//
//  LargeNotableLoot.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 16/10/2020.
//

import SwiftUI

struct LargeNotableLoot: View {
    let namespace: Namespace.ID
    
    let items: [QualityItemStub]
    
    var body: some View {
        VStack{
            HStack() {
                Text("\(items[0].name.value)")
                    .lineLimit(1)
                    .font(.body)
                    .minimumScaleFactor(0.5)
                    .whiteTextWithBlackOutlineStyle()
                Spacer()
                ItemIcon(item: items[0])
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
                    Text("\(items[1].name.value)")
                        .lineLimit(1)
                        .font(.body)
                        .minimumScaleFactor(0.5)
                        .whiteTextWithBlackOutlineStyle()
                    Spacer(minLength: 0)
                    ItemIcon(item: items[1])
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
                    Text("\(items[2].name.value)")
                        .lineLimit(1)
                        .font(.body)
                        .minimumScaleFactor(0.5)
                        .whiteTextWithBlackOutlineStyle()
                    Spacer()
                    ItemIcon(item: items[2])
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

