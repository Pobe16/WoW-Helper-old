//
//  LoadingRaids.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    
    func loadRaidsInfo(){
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            if self.raidsStubs.count > 0 {
                self.raidsStubs.removeFirst()
            }
            self.loadRaidsInfo()
            
            return
        }
        guard let currentRaidToLoad = raidsStubs.first else {
            if raids.count > 0 {
                print("finished loading raids")
                print("loaded \(raids.count) raids")
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.raids.sort()
                    }
                    self.prepareRaidEncounters()
                    self.prepareRaidBackgrounds()
                }
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadRaidsInfo()
            }
            return
        }
        
        guard !raids.contains(where: { (raid) -> Bool in
            currentRaidToLoad.id == raid.id
        }) else {
            if raidsStubs.count > 0 {
                raidsStubs.removeFirst()
            }
            loadRaidsInfo()
            return
        }
        
        let requestUrlAPIHost = "\(currentRaidToLoad.key.href)"
        
        if reloadFromCDAllowed {
            let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
            
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
                decodeRaidData(savedData.data!)
                return
            }
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2.accessToken ?? ""
        
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
                print("error, retrying in 1 second")
                print(error?.localizedDescription ?? "error")
                self.connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadRaidsInfo()
                }
                return
            }
            
            connectionRetries = 0
            DispatchQueue.main.async {
                decodeRaidData(data, fromURL: fullRequestURL)
            }
        }
        task.resume()
        
    }
    func decodeRaidData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(InstanceJournal.self, from: data)
            
//          For some reason Blizz have put a Greater Legion Invasion here as a raid…
//          I'm not allowing it.
            if dataResponse.category.type == .event {
                if raidsStubs.count > 0{
                    raidsStubs.removeFirst()
                }
                loadRaidsInfo()
                return
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            
            timeRetries = 0
                
            DispatchQueue.main.async {
                withAnimation {
                    if !self.raids.contains(where: { (instance) -> Bool in
                        instance.id == dataResponse.id
                    }) {
                        self.raids.append(dataResponse)
                    }
                    self.downloadedItems += 1
                }
                if self.raidsStubs.count > 0 {
                    self.raidsStubs.removeFirst()
                }
                self.loadRaidsInfo()
            }
            
        } catch {
            timeRetries += 1
            print(error)
            loadRaidsInfo()
        }
    }
    
}
