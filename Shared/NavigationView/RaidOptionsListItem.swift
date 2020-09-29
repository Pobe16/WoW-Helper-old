//
//  RaidOptionsListItem.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 05/09/2020.
//

import SwiftUI

struct RaidOptionsListItem: View {
    var body: some View {
        HStack{
            Image(systemName: "gear")
                .resizable()
                .foregroundColor(.accentColor)
                .scaledToFit()
                .frame(width: 63, height: 63)
                .cornerRadius(15, antialiased: true)
            Text("Settings")
            Spacer()
        }
    }
}

struct RaidOptionsListItem_Previews: PreviewProvider {
    static var previews: some View {
        RaidOptionsListItem()
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
