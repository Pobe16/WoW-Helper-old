//
//  AuthObject.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import Foundation


struct AuthInfo {
    static let ClientID: String         = secretOAuth.ClientID
    static let ClientSecret: String     = secretOAuth.ClientSecret
    static var AuthorizeUri: String {
        return (UserDefaults.standard.object(forKey: "authHost") as? String ?? BattleNetAuthorizationHostList.Europe) + "/authorize"
    }
    static var TokenUri: String {
        return (UserDefaults.standard.object(forKey: "authHost") as? String ?? BattleNetAuthorizationHostList.Europe) + "/token"
    }
    static let RedirectUris: [String]   = ["http://pobe16.github.io/wow", "wowwidget://authenticated"]
    static var Scope: String            = "wow.profile"
    static let Keychain: Bool           = true
}


