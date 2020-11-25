//
//  WidgetLogic.swift
//  WoW Helper (iOS)
//
//  Created by Mikolaj Lukasik on 23/11/2020.
//

import WidgetKit
import SwiftUI



struct WidgetLogic: View {
    @Environment(\.widgetFamily) var family
    
    let container: RaidsSuggestedForCharacter?
    
    var body: some View {
        if container != nil {
            if container!.characterLevel >= 30 && !container!.raids.isEmpty {
                switch family {
                case .systemSmall:
                    SmallNotableRaidWidget(container: container!)
                case .systemMedium:
                    MediumNotableRaidWidget(container: container!)
                case .systemLarge:
                    LargeNotableRaidWidget(container: container!)
                @unknown default:
                    SmallNotableRaidWidget(container: container!)
                }
            } else {
                if container!.characterLevel >= 30{
                    NoRaidsLeftWidget(container: container!, message: "All done!")
                } else {
                    NoRaidsLeftWidget(container: container!, message: "Level up!")
                }
            }
        } else {
            HStack{
                Spacer()
                VStack{
                    Spacer()
                    Text("WoW Helper")
                        .font(family == .systemSmall ? .title3 : .largeTitle)
                        .whiteTextWithBlackOutlineStyle()
                    Spacer()
                    Text("Please log in")
                        .whiteTextWithBlackOutlineStyle()
                    Spacer()
                }
                Spacer()
            }
            
            .background(
                Image("Goldshire_Inn")
                    .resizable()
                    .scaledToFill()
            )
        }
        
    }
}
