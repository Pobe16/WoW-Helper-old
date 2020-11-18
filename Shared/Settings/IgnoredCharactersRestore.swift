//
//  IgnoredCharactersRestore.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 27/10/2020.
//

import SwiftUI

struct IgnoredCharactersRestore: View {
    @EnvironmentObject var gameData: GameData
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    #if os(iOS)
    var listStyle = InsetGroupedListStyle()
    #elseif os(macOS)
    var listStyle =  DefaultListStyle()
    #endif
    
    var body: some View {
        List(){
            ForEach(gameData.ignoredCharacters) { character in
                HStack{
                    CharacterImage(character: character)
                    Text("\(character.name), lvl \(character.level), \(character.realm.name)")
                    Spacer()
                    Button {
                        gameData.unIgnoreCharacter(character)
                        shouldWeGoBack()
                        
                    } label: {
                        Image(systemName: "goforward.plus")
                    }

                }
                .padding()
                .listRowBackground(CharacterListItemBackground(charClass: character.playableClass, faction: character.faction, selected: false))
            }
        }
        .padding(.horizontal)
        .listStyle(listStyle)
        .background(
            BackgroundTexture(texture: .ice, wall: .horizontal)
                .edgesIgnoringSafeArea(.all)
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Readd ignored characters")
            }
        }
    }
    func shouldWeGoBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.gameData.ignoredCharacters.isEmpty {
                self.presentationMode.wrappedValue.dismiss()
            }
            
        }
    }
}

struct IgnoredCharactersRestore_Previews: PreviewProvider {
    static var previews: some View {
        IgnoredCharactersRestore()
    }
}
