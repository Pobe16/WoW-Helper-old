//
//  MainScreen.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 13/08/2020.
//

import SwiftUI

struct MainScreen: View {
    @EnvironmentObject var gameData: GameData
    @EnvironmentObject var authorization: Authentication
    @State var selection: String? = ""
    
    #if os(iOS)
    var listStyle = InsetGroupedListStyle()
    
    init() {
        UITableViewCell.appearance().selectionStyle = .none
        UITableView.appearance().backgroundColor = .clear
    }
    #elseif os(macOS)
    var listStyle =  DefaultListStyle()
    #endif
    
    var body: some View {
        NavigationView {
            List {
                
                Section(header:
                    NavListSectionHeader(text: gameData.loadingAllowed ? "Characters" : "Loading game data")
                ){
                    if gameData.characters.count > 0 {
                        ForEach(gameData.characters) { character in
                            NavigationLink(
                                destination:
                                    CharacterMainView(character: character),
                                tag: "\(character.name)-\(character.realm.slug)",
                                selection: $selection) {
                                CharacterListItem(character: character)
                            }
                            .disabled(!gameData.loadingAllowed)
                            .listRowBackground(
                                CharacterListItemBackground(
                                    charClass: character.playableClass,
                                    faction: character.faction,
                                    selected: selection == "\(character.name)-\(character.realm.slug)"
                                )
                            )
                        }
                    } else {
                        CharacterLoadingListItem()
                            .listRowBackground(
                            DefaultListItemBackground(
                                color: Color.black,
                                selected: false
                            )
                        )
                    }
                }
                Section(header:
                    NavListSectionHeader(text: "Settings")
                ){
                    NavigationLink(destination: DataHealthScreen(), tag: "data-health", selection: $selection) {
                        GameDataLoader()
                    }
                    .listRowBackground(
                        DefaultListItemBackground(
                            color: Color.blue,
                            selected: selection == "data-health"
                        )
                    )
                    
                    NavigationLink(destination: RaidOptions(), tag: "raid-settings", selection: $selection) {
                        RaidOptionsListItem()
                    }
                    .listRowBackground(
                        DefaultListItemBackground(
                            color: Color.green,
                            selected: selection == "raid-settings"
                        )
                    )
                    
                    NavigationLink(destination: LogOutDebugScreen(), tag: "log-out", selection: $selection) {
                        LogOutListItem()
                    }
                    .listRowBackground(
                        DefaultListItemBackground(
                            color: Color.black,
                            selected: selection == "log-out"
                        )
                    )
                    
                }
                
            }
            .listStyle(listStyle)
            .background(ListBackground())
            .edgesIgnoringSafeArea(.vertical)
            .toolbar{
                ToolbarItem(placement: .principal){
                    Text("WoWWidget")
                        .fontWeight(.black)
                        .shadow(color: .white, radius: 1, x: 0, y: 0)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if !gameData.loadingAllowed {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    }
                }
                    
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
            .previewLayout(.fixed(width: 2732, height: 2048))
    }
}
