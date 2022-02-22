//
//  SummaryListItem.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 04/10/2020.
//

import SwiftUI

struct SummaryListItem: View {
    var body: some View {
        HStack {
            Image(systemName: "person.2.square.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 63, height: 63)
                .cornerRadius(15, antialiased: true)
                .foregroundColor(.accentColor)
            Text("Raid Farming")
        }
    }
}

struct SummaryListItem_Previews: PreviewProvider {
    static var previews: some View {
        SummaryListItem()
    }
}
