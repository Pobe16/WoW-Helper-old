//
//  RaidFarmSection.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct RaidFarmSection: View {
    let collection: NamedRaidCollection
    let faction: Faction
    
    var body: some View {
        Section(header: RaidFarmHeader(headerText: collection.name, faction: faction) ) {
            ForEach(collection.raids) { raid in
                CharacterRaidTile(raid: raid, faction: faction)
            }
        }
    }
}

//struct RaidFarmSection_Previews: PreviewProvider {
//    static var previews: some View {
//        RaidFarmSection()
//    }
//}
