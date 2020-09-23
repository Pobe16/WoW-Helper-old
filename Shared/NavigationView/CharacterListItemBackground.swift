//
//  CharacterListItemBackground.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 21/09/2020.
//

import SwiftUI

struct WoWCharacterButtonStyle: ButtonStyle {

    let charClass: ClassInProfile
    let faction: Faction
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                CharacterListItemBackground(
                    charClass: charClass,
                    faction: faction,
                    selected: configuration.isPressed
                )
            )
    }
}

struct CharacterListItemBackground: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    let charClass: ClassInProfile
    let faction: Faction
    let selected: Bool
    
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
                            .init(
                                color: Color("faction\(faction.type)")
                                    .opacity(selected ? 1 : 0.65),
                                location: 0
                            ),
                            .init(
                                color: Color("faction\(faction.type)")
                                    .opacity(selected ? 0.8 : 0.5),
                                location: 0.20
                            ),
                            .init(
                                color: Color("class\(charClass.id)")
                                    .opacity(selected ? 0.7 : 0.4),
                                location: 0.50
                            ),
                            .init(
                                color: Color("class\(charClass.id)")
                                    .opacity(selected ? 1 : colorScheme == .dark ? 0.65 : 0.25),
                                location: 1
                            )
                        ]),
                    startPoint: .leading,
                    endPoint: .trailing)
            }
        }
        
    }
    
    func removeSpaces(_ s: String) -> String {
        return s.split(separator: " ").joined()
    }
}

struct CharacterListItemBackground_Previews: PreviewProvider {
    static var previews: some View {
        
        CharacterListItemBackground(charClass: placeholders.characterInProfile.playableClass, faction: placeholders.characterInProfile.faction, selected: false)
            .previewLayout(.fixed(width: 300, height: 80))
        
        
        CharacterListItemBackground(charClass: placeholders.characterInProfile.playableClass, faction: placeholders.characterInProfile.faction, selected: true)
            .previewLayout(.fixed(width: 300, height: 80))
        
        CharacterListItemBackground(charClass: placeholders.characterInProfile.playableClass, faction: Faction(type: "HORDE", name: "Horde"), selected: false)
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .dark)
        
        CharacterListItemBackground(charClass: placeholders.characterInProfile.playableClass, faction: Faction(type: "HORDE", name: "Horde"), selected: true)
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .dark)
    }
}
