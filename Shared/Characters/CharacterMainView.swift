//
//  CharacterMainView.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 28/08/2020.
//

import SwiftUI

struct CharacterMainView: View {
    let character: CharacterInProfile
    @State var viewSelection: Int = 0
    var body: some View {
        
        Group {
            switch viewSelection {
            case 0:
                WrapperForRaidOptions(character: character)
            case 1:
                Text("\(character.name) - \(character.realm.name) character info")
            case 2:
                Text("Coming soon")
                    .toolbar{
                        ToolbarItemGroup(placement: .status) {
                            Spacer()
                            Text("0/0")
                        }
                    }
                
            default:
                Text("#debug")
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .principal){
                Picker(selection: $viewSelection, label: Text("Character View Selection1"), content: {
                    Text("Raids").tag(0)
//                    Text("Character").tag(1)
//                    
//                    Text("Mythic+").tag(2)
//                        .disabled(character.level < 60)
                })
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
                .onChange(of: viewSelection, perform: { value in
                    saveViewSelection(value)
                })
            }
        }
        .onAppear(perform: {
            loadViewSelection()
        })
        
    }
    
    func loadViewSelection() {
        let UDKey = "\(character.name)-\(character.id)-characterViewSelection"
        viewSelection = UserDefaults.standard.integer(forKey: UDKey)
    }
    
    func saveViewSelection(_ value: Int) {
        let UDKey = "\(character.name)-\(character.id)-characterViewSelection"
        UserDefaults.standard.setValue(value, forKey: UDKey)
    }
}

struct CharacterMainView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterMainView(character: placeholders.characterInProfile)
    }
}
