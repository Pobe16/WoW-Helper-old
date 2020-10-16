//
//  SummaryOfNotableRaids.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 14/10/2020.
//

import SwiftUI

struct SummaryOfNotableRaids: View {
    @Namespace var animationsForFirstWidget
    @Namespace var animationsForSecondWidget
    @Namespace var animationsForThirdWidget
    @Namespace var animationsForFourthWidget
    
    let summarySize: summaryPreviewSize
    let character: CharacterInProfile
    let notableRaids: [CombinedRaidWithEncounters]
    let loot: [InstanceNotableItems]
    
    @State var viewWidth: CGFloat = 200
    
    var body: some View {
        
        switch summarySize {
        case .large:
            HStack {
                Spacer()
                ForEach(0...howManyRaidsToPresent(for: viewWidth), id: \.self) { raidNumber in
                
                    LargeNotableRaid(
                        namespace: selectNamespace(for: raidNumber),
                        character: character,
                        raid: notableRaids[raidNumber],
                        items: getItems(for: notableRaids[raidNumber].id)
                    )
                
                    Spacer()
                }
            }
            .background(
                GeometryReader {geo in
                    Spacer()
                        .onAppear(perform: {
                            viewWidth = geo.size.width
                        })
                    
                }
            )
        case .medium:
            HStack {
                Spacer()
                ForEach(0...howManyRaidsToPresent(for: viewWidth), id: \.self) { raidNumber in
                
                    MediumNotableRaid(
                        namespace: selectNamespace(for: raidNumber),
                        character: character,
                        raid: notableRaids[raidNumber],
                        items: getItems(for: notableRaids[raidNumber].id)
                    )
                
                    Spacer()
                }
                    
            }.background(
                GeometryReader {geo in
                    Spacer()
                        .onAppear(perform: {
                            viewWidth = geo.size.width
                        })
                    
                }
            )
        case .small:
            HStack {
                Spacer()
                ForEach(0...howManyRaidsToPresent(for: viewWidth), id: \.self) { raidNumber in
                
                    SmallNotableRaid(namespace: selectNamespace(for: raidNumber) ,character: character, raid: notableRaids[raidNumber])
                
                Spacer()
                }
                    
            }.background(
                GeometryReader {geo in
                    Spacer()
                        .onAppear(perform: {
                            viewWidth = geo.size.width
                        })
                    
                }
            )
                
        }
        
    }
    
    func getItems(for raid: Int) -> [QualityItemStub] {
        guard let raid = loot.first(where: { (loot) -> Bool in
            loot.id == raid
        }) else { return [] }
        var items: [QualityItemStub] = []
        items.append(contentsOf: raid.mounts)
        items.append(contentsOf: raid.pets)
        return items
    }
    
    func howManyRaidsToPresent(for viewSize: CGFloat) -> Int {
        let raidsCount = notableRaids.count
        if raidsCount == 1 {
            return 0
        } else {
            var sizeNeededPerOneRaid: CGFloat = 171
            switch summarySize {
            case .large, .medium: sizeNeededPerOneRaid = 322
            case .small: sizeNeededPerOneRaid = 171
            }
            var raidsThatCanFit = Int(viewSize / sizeNeededPerOneRaid) - 1
            if raidsThatCanFit < 0 { raidsThatCanFit = 0 }
            
            
            return min(raidsCount - 1, raidsThatCanFit)
        }
    }
    
    func selectNamespace(for widgetNumber: Int) -> Namespace.ID {
        switch widgetNumber {
        case 3:
            return animationsForFourthWidget
        case 2:
            return animationsForThirdWidget
        case 1:
            return animationsForSecondWidget
        case 0:
            return animationsForFirstWidget
        default:
            return animationsForFirstWidget
        }
    }
}

//struct SummaryOfNotableRaids_Previews: PreviewProvider {
//    static var previews: some View {
//        SummaryOfNotableRaids()
//    }
//}


