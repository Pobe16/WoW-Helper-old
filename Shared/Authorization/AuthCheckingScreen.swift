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
    
    var body: some View {
        Group {
            
            if authorization.loggedIn {
                MainScreen()
            } else {
                LoginScreen()
                
            }
        }
        .onAppear(perform: {
            print("onappear debug")
            determineLoginState()
        })
        .onReceive(authorization.$oauth2, perform: { _ in
            print("authorization.$oauth2 update debug")
            determineLoginState()
        })
        .onOpenURL(perform: { url in
            print("Checking the url:",url);
            processURLAuthentication(url)
        })
        
    }
    
    
    fileprivate func processURLAuthentication(_ url: URL) {
        let schemeURL = url.absoluteString
        let properAddress = schemeURL.replacingOccurrences(of: "wowwidget://authenticated", with: "http://pobe16.github.io/wow")
        let properURL = URL(string: properAddress)
        authorization.oauth2.handleRedirectURL(properURL ?? url)
    }
    
    fileprivate func determineLoginState() {
        guard authorization.loggedBefore else { return }
        guard authorization.loginAllowed else { return }
        authorization.loginAllowed = false
        let authObject = authorization.oauth2
        
//        print(authObject)
        
        guard authObject.accessToken != nil else {
            authorization.loggedIn = false
            authorization.oauth2.logger = OAuth2DebugLogger(.trace)
            #if os(iOS)
            authorization.oauth2.authConfig.authorizeEmbedded = true
            authorization.oauth2.authConfig.authorizeContext = UIApplication.shared.windows[0].rootViewController
//            #elseif os(macOS)
//            authorization.oauth2.authConfig.authorizeEmbedded = true
//            authorization.oauth2.authConfig.authorizeContext = NSApp.windows[0]
            #endif
            authorization.oauth2.authorize() { authParameters, error in
                if authParameters != nil {
                    authorization.loginAllowed      = true
                    authorization.loggedIn          = true
                } else {
                    print("Authorization was canceled or went wrong: \(String(describing: error))")   // error will not be nil
                    authorization.loginAllowed      = true
                    authorization.loggedIn          = false
                }
            }
            return
        }
        
        authorization.loggedIn = true
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthCheckingScreen()
            
    }
}
