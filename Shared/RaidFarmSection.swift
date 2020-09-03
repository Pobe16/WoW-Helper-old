//
//  RaidFarmSection.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct RaidFarmSection: View {
    let collection: NamedRaidCollection
    
    var body: some View {
        Section(header: RaidFarmHeader(headerText: collection.name) ) {
            ForEach(collection.raids) { raid in
                VStack{
                    Text("\(raid.raidName)")
                    ForEach(raid.modes, id: \.self){ mode in
                        Text("\(mode.mode.name)")
                    }
                }
                .padding()
                .frame(height: 180)
                .background(Color.gray)
                .cornerRadius(30)
            }
        }
    }
}

//struct RaidFarmSection_Previews: PreviewProvider {
//    static var previews: some View {
//        RaidFarmSection()
//    }
//}
