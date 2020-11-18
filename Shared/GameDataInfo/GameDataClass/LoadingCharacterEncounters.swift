//
//  LoadingCharacterEncounters.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    func loadCharacterRaidEncounters() {
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            if charactersForRaidEncounters.count > 0 {
                charactersForRaidEncounters.removeFirst()
            }
            if charactersForRaidEncounters.count > 0 {
                loadCharacterRaidEncounters()
                return
            }
            
            DispatchQueue.main.async { [self] in
                withAnimation {
                    loadingAllowed = true
                }
                reloadFromCDAllowed = true
            }
            if !characterRaidEncounters.isEmpty {
                DispatchQueue.main.async {
                    self.prepareSuggestedRaids()
                }
            }
            return
        }
        
        guard let character = charactersForRaidEncounters.first else {
            if characterRaidEncounters.count > 0 {
                print("finished loading character raid encounters")
                
                print(self.characterRaidEncounters.count)
                print("loaded \(characterRaidEncounters.count) character raid encounters")
                
                DispatchQueue.main.async { [self] in
                    withAnimation {
                        characterRaidEncounters.sort { characterRaidEncountersSorting(lhs: $0, rhs: $1) }
                        loadingAllowed = true
                    }
                    reloadFromCDAllowed = true
                }
                prepareSuggestedRaids()
                return
            }
            timeRetries += 1
            print("data saving problem with character encounters - retrying in 1s")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadCharacterRaidEncounters()
            }
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        
        let encodedName = character.name.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let requestUrlAPIFragment =
            "/profile/wow/character" +
            "/\(character.realm.slug)" +
            "/\(encodedName ?? character.name.lowercased())" +
            "/encounters/raids"
        let strippedAPIUrl = requestUrlAPIHost + requestUrlAPIFragment
        
        let daysNeededForRefresh: Double = reloadFromCDAllowed ? 0.01 : 0.0
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: daysNeededForRefresh) {
            
            decodeCharacterRaidEncountersData(savedData.data!)
            
            return
        }
        
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
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.01) {
                decodeCharacterRaidEncountersData(savedData.data!)
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
                print("error, retrying in 1 second")
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadCharacterRaidEncounters()
                }
                return
            }
            
            connectionRetries = 0
            decodeCharacterRaidEncountersData(data, fromURL: fullRequestURL)
            
        }
        task.resume()
    }
        
    
    func decodeCharacterRaidEncountersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        do {
            let dataResponse = try decoder.decode(CharacterRaidEncounters.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            
            timeRetries = 0
            
            DispatchQueue.main.async { [self] in
                withAnimation {
                    characterRaidEncounters.append(dataResponse)
                    downloadedItems += 1
                }
                if charactersForRaidEncounters.count > 0 {
                    charactersForRaidEncounters.removeFirst()
                }
                loadCharacterRaidEncounters()
            }
            
            

        } catch {
            timeRetries += 1
            print(error)
            loadCharacterRaidEncounters()
        }
    }
}
