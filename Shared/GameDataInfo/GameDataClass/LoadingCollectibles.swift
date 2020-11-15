//
//  LoadingCollectibles.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    func loadAccountMounts() {
        
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/user/wow/collections/mounts"
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
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.1) {
                decodeAccountMounts(savedData.data!)
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
                loadAccountMounts()
                
                return
            }
            
            connectionRetries = 0
            decodeAccountMounts(data, fromURL: fullRequestURL)
            
        }
        task.resume()
    }
    
    func decodeAccountMounts(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(MountsCollection.self, from: data)
            
            guard let mounts = dataResponse.mounts else {
                print("no account mounts present")
                loadExpansionIndex()
                return
                
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            var mountsNotYetObtained: [CollectibleItem] = []
            
            for dropMount in mountItemsList {
                if !mounts.contains(where: { (collectionMount) -> Bool in
                    collectionMount.mount.id == dropMount.collectionID
                }) {
                    mountsNotYetObtained.append(dropMount)
                }
            }
            
            mountsStillToObtain.append(contentsOf: mountsNotYetObtained)
            loadAccountPets()
            
            
        } catch {
            print("Error while decoding mounts")
            print(error)
            loadAccountPets()
        }
    }
    
    func loadAccountPets() {
        
        if timeRetries > 3 || connectionRetries > 3 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            timeRetries = 0
            connectionRetries = 0
            loadExpansionIndex()
            return
        }
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/user/wow/collections/pets"
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
        
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.1) {
                decodeAccountMounts(savedData.data!)
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
                loadAccountPets()
                return
            }
            
            decodeAccountPets(data, fromURL: fullRequestURL)
            
        }
        task.resume()
    }
    
    func decodeAccountPets(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(PetsCollection.self, from: data)
            
            guard let pets = dataResponse.pets else {
                print("no account pets present")
                loadExpansionIndex()
                return
                
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            var petsNotYetObtained: [CollectibleItem] = []
            
            for dropPet in petItemsList {
                if !pets.contains(where: { (collectionPet) -> Bool in
                    collectionPet.species.id == dropPet.collectionID
                }) {
                    petsNotYetObtained.append(dropPet)
                }
            }
            
            petsStillToObtain.append(contentsOf: petsNotYetObtained)
            loadExpansionIndex()
            
        } catch {
            print("Error while decoding pets")
            print(error)
            loadExpansionIndex()
        }
    }
    
}
