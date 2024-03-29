//
//  MainScreen.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 13/08/2020.
//

import SwiftUI

struct MainScreen: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
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
                if !gameData.loadingAllowed &&
                    (gameData.downloadedItems + 2) < max(
                        gameData.estimatedItemsToDownload,
                        gameData.actualItemsToDownload
                    ) {
                    VStack {
                        Text("Loading…")
                        ProgressView(
                            value: Double(gameData.downloadedItems),
                            total: Double(max(gameData.estimatedItemsToDownload, gameData.actualItemsToDownload))
                        )
                    }
                    .listRowBackground(
                        DefaultListItemBackground(
                            color: Color.yellow,
                            selected: selection == "summary"
                        )
                    )
                }

                Section(header:
                    NavListSectionHeader(text: "Summary")
                ) {

                    NavigationLink(
                        destination:
                            SummaryMain(),
                        tag: "summary",
                        selection: $selection) {
                        SummaryListItem()
                    }
                    .listRowBackground(
                        DefaultListItemBackground(
                            color: Color.green,
                            selected: selection == "summary"
                        )
                    )
                }

                Section(header:
                    NavListSectionHeader(text: "Characters")
                ) {
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
                        .onMove(perform: gameData.changeCharactersOrder)
                        .onDelete(perform: gameData.ignoreCharacter)
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
                ) {
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
                            color: Color.orange,
                            selected: selection == "raid-settings"
                        )
                    )

                    NavigationLink(destination: Credits(), tag: "credits", selection: $selection) {
                        CreditsListItem()
                    }
                    .listRowBackground(
                        DefaultListItemBackground(
                            color: Color.purple,
                            selected: selection == "credits"
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
            .background(
                BackgroundTexture(texture: .wood, wall: .horizontal)
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("WoWHelper")
                        .fontWeight(.black)
                        .whiteTextWithBlackOutlineStyle()
                }
                ToolbarItem(placement: .primaryAction) {
                    if !gameData.loadingAllowed {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .font(Font.title3.bold())
                    } else {
                        #if os(iOS)
                        EditButton()
                            .font(Font.title3.bold())
                        #endif
                    }
                }
            }
            SummaryMain()
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .onAppear {
            gameData.loadGameData(authorizedBy: authorization)
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
            .previewLayout(.fixed(width: 2732, height: 2048))
    }
}
