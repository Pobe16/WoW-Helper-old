//
//  Authentication.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import OAuth2
import Foundation


class Authentication: ObservableObject {
    @Published var settings: OAuth2JSON = [
        "client_id":                    AuthInfo.ClientID,
        "client_secret":                AuthInfo.ClientSecret,
        "authorize_uri":                AuthInfo.AuthorizeUri,
        "token_uri":                    AuthInfo.TokenUri,
        "redirect_uris":                AuthInfo.RedirectUris,
        "scope":                        AuthInfo.Scope,
        "keychain":                     AuthInfo.Keychain
    ]
    
    @Published var oauth2 : OAuth2CodeGrant?
    
    public func refreshSettings() {
        self.settings = [
            "client_id":                    AuthInfo.ClientID,
            "client_secret":                AuthInfo.ClientSecret,
            "authorize_uri":                AuthInfo.AuthorizeUri,
            "token_uri":                    AuthInfo.TokenUri,
            "redirect_uris":                AuthInfo.RedirectUris,
            "scope":                        AuthInfo.Scope,
            "keychain":                     AuthInfo.Keychain
        ] as OAuth2JSON
        
        self.oauth2 = OAuth2CodeGrant(settings: self.settings)
    }

}

class AuthenticationCheck: ObservableObject {
    @Published var UserIsLoggedIn: Bool = false
}
