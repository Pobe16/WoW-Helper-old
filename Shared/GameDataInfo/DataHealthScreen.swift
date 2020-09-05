//
//  DataHealthScreen.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import SwiftUI

struct DataHealthScreen: View {
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    @State var gameDataCreationDate: String = "Loading"
    @State var timeRetries: Int = 0
    @State var connectionRetries: Int = 0
    
    var body: some View {
        ScrollView(Axis.Set.vertical, showsIndicators: true) {
            VStack{
                if gameData.expansions.count > 0 {
                    ForEach(gameData.expansions){ expansion in
                        ExpansionGameDataPreview( expansion: expansion )
                    }
                } else {
                    EmptyView()
                }
                Text("Last refreshed: \(gameDataCreationDate)")
                Spacer(minLength: 20)

            }
            
        }
        .onAppear(perform: {
            checkDataCreationDate()
            gameData.continueLoadingDungeons(authorizedBy: authorization)
        })
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("Expansions")
            }
            ToolbarItem(placement: .primaryAction) {
                if gameData.loadingAllowed {
                    Button {
                        gameData.hardReloadGameData(authorizedBy: authorization)
                    } label: {
                        Text("Refresh!")
                    }
                } else {
                    ProgressView(
                        value: Double(gameData.downloadedItems),
                        total: Double(max(gameData.estimatedItemsToDownload, gameData.actualItemsToDownload))
                        
                    )
                    .frame(width: 80)
                }
            }
        }
        
    }
    
    func checkDataCreationDate(){
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: "APIRegionHost") as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/journal-expansion/index"
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlAPIHost + requestUrlAPIFragment, maximumAgeInDays: 90) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale.current
            let dateString = dateFormatter.string(from: savedData.creationDate!)
            gameDataCreationDate = dateString
        } else {
            gameDataCreationDate = "Nothing saved"
        }
    }
    
    
    
}
