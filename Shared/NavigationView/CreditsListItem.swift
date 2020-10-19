//
//  CreditsListItem.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 18/10/2020.
//

import SwiftUI

struct CreditsListItem: View {
    var body: some View {
        HStack{
            Image(systemName: "text.book.closed")
                .resizable()
                .foregroundColor(.accentColor)
                .scaledToFit()
                .frame(width: 63, height: 63)
                .cornerRadius(15, antialiased: true)
            Text("Credits")
            Spacer()
        }
    }
}

struct CreditsListItem_Previews: PreviewProvider {
    static var previews: some View {
        CreditsListItem()
    }
}
