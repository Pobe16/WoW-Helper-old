//
//  WoWHelperApp.swift
//  Shared
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import OAuth2
import SwiftUI

@main
struct WoWHelperApp: App {
    @ObservedObject var auth        = Authentication()
    @ObservedObject var gameData    = GameData()
    @ObservedObject var order       = FarmCollectionsOrder()
    
    var body: some Scene {
        WindowGroup {
            AuthCheckingScreen()
                .environmentObject(auth)
                .environmentObject(gameData)
                .environmentObject(order)
                .onAppear(perform: {
                    initDebug()
                })
        }
    }
    
    fileprivate func initDebug(){
//        UserDefaults.resetStandardUserDefaults()
//        let imagesInCoreData = CoreDataImagesManager.shared.fetchAllImages()
//        print(imagesInCoreData?[0].creationDate)
//        auth.oauth2.logger = OAuth2DebugLogger(.trace)
    }
    
}
