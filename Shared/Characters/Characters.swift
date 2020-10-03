//
//  Characters.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/10/2020.
//

import Foundation
import SwiftUI

struct CharacterOrderNames: Hashable, Identifiable, Comparable, Codable {
    static func < (lhs: CharacterOrderNames, rhs: CharacterOrderNames) -> Bool {
        lhs.order < rhs.order
    }
    
    var id: Int
    var order: Int
    var name: String
}

class Characters: ObservableObject {
    var authorization: Authentication                       = Authentication()
    var timeRetries                                         = 0
    var connectionRetries                                   = 0
    var reloadFromCDAllowed                                 = true
    
    @Published var characters: [CharacterInProfile]         = []
    @Published var order:   [CharacterOrderNames]           = []
    @Published var raidsEncounters: [Any]                   = []
    
    func loadCharacters(authorizedBy auth: Authentication) {
        
        reloadFromCDAllowed = true
        authorization = auth
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/user/wow"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
//        print(fullRequestURL)
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
//                print(data)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let dataResponse = try decoder.decode(UserProfile.self, from: data)
                    
                    for account in dataResponse.wowAccounts {
                        DispatchQueue.main.async {
                            withAnimation {
                                self.characters.append(contentsOf: account.characters)
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
                
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
