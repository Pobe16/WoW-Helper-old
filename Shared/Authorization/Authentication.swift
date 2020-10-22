//
//  Authentication.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import OAuth2
import Foundation


class Authentication: ObservableObject {
    @Published var settings     : OAuth2JSON
    @Published var oauth2       : OAuth2CodeGrant
    @Published var loggedIn     : Bool
    @Published var loginAllowed : Bool
    @Published var loggedBefore : Bool
    
    
    public func refreshSettings() {
        self.oauth2             = OAuth2CodeGrant(settings: self.settings)
    }
    
    init() {
        let startSettings = [
            "client_id"         :       AuthInfo.ClientID,
            "client_secret"     :       AuthInfo.ClientSecret,
            "authorize_uri"     :       AuthInfo.AuthorizeUri,
            "token_uri"         :       AuthInfo.TokenUri,
            "redirect_uris"     :       AuthInfo.RedirectUris,
            "scope"             :       AuthInfo.Scope,
            "keychain"          :       AuthInfo.Keychain
        ] as OAuth2JSON
        
        settings                = startSettings
        oauth2                  = OAuth2CodeGrant.init(settings: startSettings)
        loggedIn                = false
        loginAllowed            = true
        loggedBefore            = UserDefaults.standard.bool(forKey: UserDefaultsKeys.UserLoggedBefore)
        
    }

}
