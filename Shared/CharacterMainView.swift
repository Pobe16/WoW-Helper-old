//
//  CharacterMainView.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 28/08/2020.
//

import SwiftUI

struct CharacterMainView: View {
    @State var character: CharacterInProfile
    @State var viewSelection: Int = 0
    var body: some View {
        
        
        ScrollView {
            switch viewSelection {
            case 0:
                Text("\(character.name) \(character.realm.name)")
            case 1:
                Text("\(character.name) \(character.realm.name) farming raids")
            case 2:
                Text("\(character.name) \(character.realm.name) mounts collection")
                
            default:
                Text("\(character.name) \(character.realm.name)")
            }
            
        }
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Picker(selection: $viewSelection, label: Text("Character View Selection"), content: {
                    Text("\(character.name)").tag(0)
                    Text("Raids").tag(1)
                    Text("Mounts").tag(2)
                })
                .pickerStyle(SegmentedPickerStyle())
//                .labelsHidden()
                .onChange(of: viewSelection, perform: { value in
                    saveViewSelection(value)
                })
            }
        })
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
