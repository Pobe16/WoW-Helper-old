//
//  LoadingCharacters.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    func loadCharacters() {
        withAnimation {
            loadingAllowed = false
        }
        
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            return
        }
        
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
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(fullRequestURL.absoluteString)
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.04) {
                decodeCharactersData(savedData.data!)
                return
            }
        }
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                
                // something went wrong, check the error
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                loadCharacters()
                
                return
            }
            
            connectionRetries = 0
            decodeCharactersData(data, fromURL: fullRequestURL)
            
        }
        task.resume()
    }
    
    func decodeCharactersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(UserProfile.self, from: data)
            
            guard let accounts = dataResponse.wowAccounts else {
                print("no wow accounts present")
                loadExpansionIndex()
                return
                
            }
            
            var accountCharacters: [CharacterInProfile] = []
            
            for account in accounts {
                accountCharacters.append(contentsOf: account.characters)
            }
            
            addOrderToCharacters(accountCharacters)
            
        } catch {
            print(error)
        }
    }
}
