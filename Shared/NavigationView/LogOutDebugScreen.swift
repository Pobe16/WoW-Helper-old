//
//  LogOutDebugScreen.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import SwiftUI

struct LogOutDebugScreen: View {
    @Binding var loggedIn: Bool
    @EnvironmentObject var authorization: Authentication
    var body: some View {
        Text("You should be logged out shortly")
            .onAppear(perform: {
                self.logOut()
            })
    }
    
    fileprivate func logOut() {
        authorization.oauth2?.forgetTokens()
        loggedIn = false
    }
}
