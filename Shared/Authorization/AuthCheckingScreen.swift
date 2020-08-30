//
//  AuthCheckingScreen.swift
//  Shared
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import OAuth2
import SwiftUI


struct AuthCheckingScreen: View {
    
    @EnvironmentObject var authorization: Authentication
    @State var loggedIn = false
    
    var body: some View {
        Group {
            
            if loggedIn {
                MainScreen(loggedIn: $loggedIn)
            } else {
                LoginScreen(loggedIn: $loggedIn)
                
            }
        }
        .onAppear(perform: {
            determineLoginState()
        })
        .onReceive(authorization.$oauth2, perform: { _ in
//            print("authorization.$oauth2 update debug")
            determineLoginState()
        })
        .onOpenURL(perform: { url in
            processURLAuthentication(url)
        })
        
    }
    
    
    fileprivate func processURLAuthentication(_ url: URL) {
        let schemeURL = url.absoluteString
        let properAddress = schemeURL.replacingOccurrences(of: "wowwidget://authenticated", with: "http://pobe16.github.io/wow")
        let properURL = URL(string: properAddress)
        authorization.oauth2?.handleRedirectURL(properURL ?? url)
    }
    
    fileprivate func logOut() {
        authorization.oauth2?.forgetTokens()
        loggedIn = false
    }
    
    fileprivate func determineLoginState() {
        guard let authObject = authorization.oauth2 else {
            loggedIn = false
            return
        }
        
        guard authObject.accessToken != nil else {
            loggedIn = false
            #if os(iOS)
            authorization.oauth2?.authConfig.authorizeEmbedded = true
            authorization.oauth2?.authConfig.authorizeContext = UIApplication.shared.windows[0].rootViewController
            #endif
            authorization.oauth2?.authorize() { authParameters, error in
                if authParameters != nil {
                    loggedIn = true
                } else {
                    print("Authorization was canceled or went wrong: \(String(describing: error))")   // error will not be nil
                }
            }
            return
        }
        
        loggedIn = true
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthCheckingScreen()
            
    }
}
