//
//  ContentView.swift
//  Shared
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import OAuth2
import SwiftUI


struct AuthScreen: View {
    
    @EnvironmentObject var authorization: Authentication
    @State var loggedIn = false
    
    var body: some View {
        Group {
            
            if loggedIn {
                Button(action: {
                    self.logOut()
                }, label: {
                    Text("Log me out!")
                })
            } else {
                LoginScreen(loggedIn: loggedIn)
                
            }
        }
        .onAppear(perform: {
            determineLoginState()
        })
        .onReceive(authorization.$oauth2, perform: { _ in
            print("authorization.$oauth2 update debug")
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
        
        print(authorization.oauth2?.accessToken as Any)
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
            return
        }
        loggedIn = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthScreen()
            
    }
}
