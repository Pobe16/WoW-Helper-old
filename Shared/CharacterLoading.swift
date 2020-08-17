//
//  CharacterLoading.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 16/08/2020.
//

import SwiftUI

struct CharacterLoading: View {
    var body: some View {
        HStack{
            Image(systemName: "wave.3.right")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .cornerRadius(15, antialiased: true)
            Spacer()
            Text("Loading…")
            Spacer()
            Image(systemName: "wave.3.left")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .cornerRadius(15, antialiased: true)
        }
    }
}

struct CharacterLoading_Previews: PreviewProvider {
    static var previews: some View {
        CharacterLoading()
            .previewLayout(.fixed(width: 300, height: 50))
            .padding()
            .previewDisplayName("One line")
    }
}
