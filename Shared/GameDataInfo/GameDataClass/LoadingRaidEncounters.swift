//
//  LoadingRaidEncounters.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    func prepareRaidEncounters() {
        raids.forEach { (instance) in
            raidEncountersStubs.append(instance.id)
        }
        DispatchQueue.main.async { [self] in
            withAnimation {
                actualItemsToDownload += raidEncountersStubs.count
            }
            loadRaidEncountersInfo()
        }
        
    }
    
    func loadRaidEncountersInfo(){
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            if raidEncounters.count > 0 {
                raidEncounters.removeFirst()
            }
            loadRaidEncountersInfo()
            
            return
        }
        guard let currentRaidEncountersToLoad = raidEncountersStubs.first else {
            if raidEncounters.count > 0 {
                print("finished loading raid encounters")

                DispatchQueue.main.async {
                    withAnimation {
                        self.raidEncounters = self.raidEncounters.sorted()
                    }
                }
                
                print("loaded \(raidEncounters.count) raid encounters")
                
                loadCharacterRaidEncounters()
                
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadRaidEncountersInfo()
            }
            return
        }
        
        guard !raidEncounters.contains(where: { (raidEncounter) -> Bool in
            currentRaidEncountersToLoad == raidEncounter.instance.id
        }) else {
            if raidEncounters.count > 0 {
                raidEncounters.removeFirst()
            }
            loadRaidEncountersInfo()
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/search/journal-encounter"
        let requestUrlSearchElement = "?instance.id=\(currentRaidEncountersToLoad)"
        let requestUrlIdentifiablePart = requestUrlAPIHost + requestUrlAPIFragment + requestUrlSearchElement
        let URLIdentifier = URL(string: requestUrlIdentifiablePart)!
        
        if reloadFromCDAllowed {
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlIdentifiablePart, maximumAgeInDays: 90) {
                decodeRaidEncountersData(savedData.data!)
                return
            }
        }
        
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "static-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlIdentifiablePart +
                                    "&namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        
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
                    loadRaidEncountersInfo()
                }
                return
            }
            self.connectionRetries = 0
            
            DispatchQueue.main.async {
                self.decodeRaidEncountersData(data, fromURL: URLIdentifier)
            }
        }
        task.resume()
        
    }
    
    func decodeRaidEncountersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            let dataResponse = try decoder.decode(JournalEncounterSearch.self, from: data)
            let wrapper = dataResponse.results
            var results: [JournalEncounter] = []
            
            wrapper.forEach { (wrapper) in
                results.append(wrapper.data)
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            timeRetries = 0
                
            DispatchQueue.main.async {
                
                withAnimation {
                    self.raidEncounters.append(contentsOf: results)
                    self.downloadedItems += 1
                }
                
                if self.raidEncountersStubs.count > 0 {
                    self.raidEncountersStubs.removeFirst()
                }
                self.loadRaidEncountersInfo()
            }
            
        } catch {
            timeRetries += 1
            print(error)
            loadRaidEncountersInfo()
        }
    }
}
