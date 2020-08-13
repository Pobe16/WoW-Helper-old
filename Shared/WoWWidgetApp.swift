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
    
    @ObservedObject var auth = Authentication.init()
    
    var body: some Scene {
        WindowGroup {
            AuthScreen()
                .environmentObject(auth)
                .onAppear(perform: {
                    authInit()
                })
        }
    }
    
    fileprivate func authInit(){
        auth.oauth2 = OAuth2CodeGrant.init(settings: auth.settings)
    }
    
}
