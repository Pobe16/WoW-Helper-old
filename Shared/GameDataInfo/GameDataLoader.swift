//
//  GameDataLoader.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 21/08/2020.
//

import SwiftUI

struct GameDataLoader: View {
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    @State var timeRetries: Int = 0
    @State var connectionRetries: Int = 0
    
    var body: some View {
        HStack{
            Image(systemName: "chart.bar.doc.horizontal")
                .resizable()
                .foregroundColor(.accentColor)
                .frame(width: 63, height: 63)
                .cornerRadius(15, antialiased: true)
            Text("Data Health")
            if !gameData.loadingAllowed &&
                (gameData.downloadedItems + 2) < max(
                    gameData.estimatedItemsToDownload,
                    gameData.actualItemsToDownload
                ) {
                ProgressView(
                    value:  Double(gameData.downloadedItems),
                    total: Double(max(gameData.estimatedItemsToDownload, gameData.actualItemsToDownload))
                )
            } else {
                Spacer()
            }
            
        }
    }
}

