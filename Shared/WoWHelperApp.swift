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

    let matchingSet: Set = ["*"]
    let allowingSet: Set = ["*"]
    let preferringSet: Set = ["authenticated"]

    var body: some Scene {
        WindowGroup {
            systemStartingScreen
                .onAppear(perform: {
                    initDebug()
                })
                .handlesExternalEvents(preferring: preferringSet, allowing: allowingSet)
        }
        .handlesExternalEvents(
            matching: matchingSet
        )
    }
    fileprivate func initDebug() {
//        UserDefaults.resetStandardUserDefaults()
//        let imagesInCoreData = CoreDataImagesManager.shared.fetchAllImages()
//        print(imagesInCoreData?[0].creationDate)
//        auth.oauth2.logger = OAuth2DebugLogger(.trace)
    }
}
