//
//  SummaryMain.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 05/10/2020.
//

import SwiftUI

enum summaryPreviewSize: String {
    case large  = "Large"
    case medium = "Medium"
    case small  = "Small"
}

struct SummaryMain: View {
    @EnvironmentObject var gameData: GameData
    
    @State var summarySize: summaryPreviewSize = .large
    
    #if os(iOS)
    let raidSettingPlacement: ToolbarItemPlacement = .primaryAction
    #elseif os(macOS)
    let raidSettingPlacement: ToolbarItemPlacement = .confirmationAction
    #endif
    
    var body: some View {
        if gameData.loadingAllowed {
            ScrollView {
                VStack{
                    if gameData.characterRaidEncounters.count > 0 {
                        ForEach(gameData.characterRaidEncounters, id: \.character.id) { GDCharacterEncounters in
                            SingleCharacterSummary(
                                summarySize: summarySize,
                                character: getCharacterBasedOn(encounters: GDCharacterEncounters),
                                characterEncounters: GDCharacterEncounters
                            )
                        }
                    } else if gameData.characters.count > 0 {
                        HStack{
                            Text("No characters in raiding level.")
                                .font(.title2)
                                .padding()
                            Spacer()
                        }
                        ForEach(gameData.characters, id: \.id) { GDCharacter in
                            HStack{
                                Text("Level up \(GDCharacter.name) to at least level 30")
                                    .font(.title3)
                                    .padding()
                                Spacer()
                            }
                        }
                    } else {
                        HStack{
                            Text("No characters found on account.")
                                .font(.title2)
                            Spacer()
                        }
                    }
                    Spacer(minLength: 80)
                }
            }
            .background(BackgroundTexture(texture: .flagstone, wall: .horizontal))
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    Text("Farming opportunities:")
                        .font(.title2)
                }
                ToolbarItem(placement: raidSettingPlacement) {
                    Menu {
                        Picker(selection: $summarySize.animation(.linear(duration: 0.2)), label: Text("")) {
                            Text(summaryPreviewSize.large.rawValue).tag(summaryPreviewSize.large)
                            Text(summaryPreviewSize.medium.rawValue).tag(summaryPreviewSize.medium)
                            Text(summaryPreviewSize.small.rawValue).tag(summaryPreviewSize.small)
                        }
                    }
                    label: {
                        Label("Preview Size", systemImage: "gear")
                            .font(.title3)
                    }
                }
            })
            .onAppear( perform: { loadOptionsSelection() } )
            .onChange(of: summarySize) { (value) in
                saveOptionsSelection(value)
            }
        } else {
            DataLoadingInfo()
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        Text("Loading game data…")
                            .font(.title3)
                    }
                })
        }
        
    }
    
    func getCharacterBasedOn(encounters: CharacterRaidEncounters) -> CharacterInProfile {
        let character = gameData.characters.first { (GDCharacter) -> Bool in
            GDCharacter.name == encounters.character.name && GDCharacter.realm.name == encounters.character.realm.name
        }
        return character!
    }
    
    func loadOptionsSelection() {
        let option = UserDefaults.standard.object(forKey: UserDefaultsKeys.summaryPreviewSize) as? String ?? summaryPreviewSize.large.rawValue
        summarySize = summaryPreviewSize(rawValue: option) ?? summaryPreviewSize.large
    }
    
    func saveOptionsSelection(_ value: summaryPreviewSize) {
        UserDefaults.standard.setValue(value.rawValue, forKey: UserDefaultsKeys.summaryPreviewSize)
    }
}


