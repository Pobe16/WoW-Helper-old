//
//  LoadingExpansions.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    func loadExpansionIndex() {
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/journal-expansion/index"
            
        if reloadFromCDAllowed {
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlAPIHost + requestUrlAPIFragment, maximumAgeInDays: 90) {
                decodeExpansionIndexData(savedData.data!)
                return
            }
        }
        
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "static-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            self.decodeExpansionIndexData(data, fromURL: fullRequestURL)
            
        }
        task.resume()
    }
    
    func decodeExpansionIndexData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionTop.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            DispatchQueue.main.async {
                self.expansionsStubs = dataResponse.tiers
                self.actualItemsToDownload += dataResponse.tiers.count
                self.loadExpansionJournal()
            }
            
            
        } catch {
            print("Error while decoding expansion Index Data")
            print(error)
        }
    }
    
    func loadExpansionJournal() {
        
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            
            timeRetries = 0
            connectionRetries = 0
            
            if expansionsStubs.count > 0 {
                expansionsStubs.removeFirst()
            }
            
            loadExpansionJournal()
            return
        }
        
        guard let stub = expansionsStubs.first else {
            if expansions.count > 0 {
                print("finished loading expansions")
                print("loaded \(expansions.count) expansions")
                DispatchQueue.main.async { [self] in
                    withAnimation {
                        expansions.sort()
                        actualItemsToDownload += raidsStubs.count
                    }
                    loadRaidsInfo()
                }
                
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("data saving problem - retrying in 1s")
                self.loadExpansionJournal()
            }
            return
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2.accessToken ?? ""
        
        let requestUrlAPIHost = "\(stub.key.href)"
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
                decodeExpansionJournalData(savedData.data!)
                return
            }
        }
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(accessToken)"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                
                print(error?.localizedDescription ?? "error")
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadExpansionJournal()
                }
                return
            }
            
            timeRetries = 0
            connectionRetries = 0
            
            decodeExpansionJournalData(data, fromURL: fullRequestURL)
        }
        task.resume()
        
        
    }
    
    func decodeExpansionJournalData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionJournal.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async { [self] in
                
                withAnimation {
                    expansions.append(dataResponse)
                    downloadedItems += 1
                }
                
                raidsStubs.append(contentsOf: dataResponse.raids ?? [])
                
                if expansionsStubs.count > 0 {
                    expansionsStubs.removeFirst()
                }
                
                loadExpansionJournal()
            }
            
            
        } catch {
            print(error)
        }
    }
}
