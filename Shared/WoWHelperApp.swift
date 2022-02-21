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
            systemStartingScreen
                .onAppear(perform: {
                    initDebug()
                })
                .handlesExternalEvents(preferring: Set(arrayLiteral: "authenticated"), allowing: Set(arrayLiteral: "*"))
        }
        .handlesExternalEvents(
            matching: Set(arrayLiteral: "*")
        )
    }
    
    #if os(iOS)
    var systemStartingScreen: some View {
        startingScreen
    }
    #elseif os(macOS)
    var systemStartingScreen: some View {
        startingScreen
            .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 600, idealHeight: 800, maxHeight: .infinity, alignment: .center)
    }
    #endif
    
    var startingScreen: some View {
        AuthCheckingScreen()
            .environmentObject(auth)
            .environmentObject(gameData)
            .environmentObject(order)
    }
    
    fileprivate func initDebug(){
//        UserDefaults.resetStandardUserDefaults()
//        let imagesInCoreData = CoreDataImagesManager.shared.fetchAllImages()
//        print(imagesInCoreData?[0].creationDate)
//        auth.oauth2.logger = OAuth2DebugLogger(.trace)
    }
    
}
