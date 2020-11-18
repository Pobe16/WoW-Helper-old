//
//  CharacterListItem.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 14/08/2020.
//

import SwiftUI

struct CharacterListItem: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    @State var character: CharacterInProfile
    
    
    var body: some View {
        HStack {
            
            CharacterImage(character: character)
            
            // only show text shadow in dark mode
            if colorScheme == .light {
                // \u{00a0} is a non-breaking space
                Text("\(character.name) lvl:\u{00a0}\(character.level)")
            } else {
                Text("\(character.name) lvl:\u{00a0}\(character.level)")
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


