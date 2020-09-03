//
//  RaidFarmHeader.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct RaidFarmHeader: View {
    
    let headerText: String
    
    var body: some View {
        HStack{
            Text(headerText)
                .font(.subheadline)
                .padding()
                .padding(.leading, 10)
            Spacer()
        }
        .background(Color.gray.opacity(0.8))
        .cornerRadius(20)
    }
}

struct RaidFarmHeader_Previews: PreviewProvider {
    static var previews: some View {
        RaidFarmHeader(headerText: "Completed raids.")
    }
}
