//
//  WoWWidgetApp.swift
//  Shared
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import OAuth2
import SwiftUI

@main
struct WoWWidgetApp: App {
    
    @ObservedObject var auth        = Authentication.init()
    @ObservedObject var gameData    = GameData.init()
    
    var body: some Scene {
        WindowGroup {
            AuthCheckingScreen()
                .environmentObject(auth)
                .environmentObject(gameData)
                .onAppear(perform: {
                    authInit()
                })
        }
    }
    
    fileprivate func authInit(){
//        UserDefaults.resetStandardUserDefaults()
        
        auth.oauth2 = OAuth2CodeGrant.init(settings: auth.settings)
        
//        let imagesInCoreData = CoreDataImagesManager.shared.fetchImages()
//        print(imagesInCoreData?[0].creationDate)
        
//        auth.oauth2?.logger = OAuth2DebugLogger(.trace)
    }
    
}
