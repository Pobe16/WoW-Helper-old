//
//  CharacterListItemBackground.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 21/09/2020.
//

import SwiftUI

struct CharacterListItemBackground: View {
    let charClass: ClassInProfile
    let faction: Faction
    
    #if os(iOS)
    let backgroundColor = UIColor.secondarySystemBackground
    #elseif os(macOS)
    let backgroundColor = NSColor.windowBackgroundColor
    #endif
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Color(backgroundColor)
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: Color("faction\(faction.name)"), location: 0),
                            .init(color: Color("faction\(faction.name)"), location: 0.15),
                            .init(color: Color("class\(removeSpaces(charClass.name))"), location: 0.85),
                            .init(color: Color("class\(removeSpaces(charClass.name))"), location: 1),
                        ]),
                    startPoint: .leading,
                    endPoint: .trailing)
                    .opacity(0.5)
            }
        }
        
    }
    
    func removeSpaces(_ s: String) -> String {
        return s.split(separator: " ").joined()
    }
}

struct CharacterListItemBackground_Previews: PreviewProvider {
    static var previews: some View {
        CharacterListItemBackground(charClass: placeholders.characterInProfile.playableClass, faction: placeholders.characterInProfile.faction)
    }
}
