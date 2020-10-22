//
//  LogOutDebugScreen.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import SwiftUI

struct LogOutDebugScreen: View {
    @EnvironmentObject var authorization: Authentication
    var body: some View {
        Text("You should be logged out shortly")
            .onAppear(perform: {
                logOut()
            })
    }
    
    fileprivate func logOut() {
        authorization.oauth2.forgetTokens()
        authorization.loggedIn = false
        authorization.loggedBefore = false
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.UserLoggedBefore)
    }
}
