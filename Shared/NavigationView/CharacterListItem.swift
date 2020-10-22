//
//  CharacterListItem.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 14/08/2020.
//

import SwiftUI

struct CharacterListItem: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    @EnvironmentObject var authorization: Authentication
    @State var characterMedia: CharacterMedia?
    let character: CharacterInProfile
    @State var characterImageData: Data? = nil
    
    
    var body: some View {
        HStack {
            
            CharacterImage(character: character)
            
            // only show text shadow in dark mode
            if colorScheme == .light {
                Text("\(character.name) lvl: \(character.level)")
            } else {
                Text("\(character.name) lvl: \(character.level)")
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
            }
            
        }
    }
}

struct CharacterListItem_Previews: PreviewProvider {
    static var previews: some View {
        CharacterListItem(character: placeholders.characterInProfile)
    }
}


