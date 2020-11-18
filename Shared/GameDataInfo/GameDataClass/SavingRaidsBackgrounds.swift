//
//  SavingRaidsBackgrounds.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    
    func prepareRaidBackgrounds() {
        for raid in raids {
            checkForStoredImage(for: raid)
        }
    }
    
    func checkForStoredImage(for instance: InstanceJournal) {
        guard timeRetries < 2, connectionRetries < 2 else {
            return
        }
        let instanceNameTransformed = instance.name.lowercased().replacingOccurrences(of: " ", with: "-")
        let nameForImage = "\(instanceNameTransformed)-\(instance.id)-\(CoreDataIDFragments.instanceBackground)"
        
        guard let storedImage = CoreDataImagesManager.shared.fetchImage(withName: nameForImage, maximumAgeInDays: 100) else {
            
            loadInstanceMediaData(for: instance, saveAs: nameForImage)
            return
        }
        DispatchQueue.main.async {
            self.updateRaidInstanceBackground(for: instance, with: storedImage.data!)
        }
        
    }
    
    func loadInstanceMediaData(for instance: InstanceJournal, saveAs imageName: String) {
        
        let requestUrlJournalMedia = instance.media.key.href
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? APIRegionHostList.Europe
        
        let fullRequestURL = URL(string:
                                    requestUrlJournalMedia +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.timeRetries += 1
                    print("retrying in 1s")
                    self.loadInstanceMediaData(for: instance, saveAs: imageName)
                }
                return
            }
            
            self.decodeMedia(data, fromURL: fullRequestURL, saveImageAs: imageName, instance: instance)
                
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task.resume()
        
    }
    
    func decodeMedia(_ data: Data, fromURL url: URL? = nil, saveImageAs imageName: String, instance: InstanceJournal) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(BlizzardMediaFormat.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            guard let backgroundURL = dataResponse.assets.filter({$0.key == "tile"}).first?.value else {
                return
            }
            
            downloadNewImage(from: backgroundURL, saveImageAs: imageName, for: instance)
            
        } catch {
            print(error)
        }
    }
    
    func downloadNewImage(from url: String, saveImageAs imageName: String, for instance: InstanceJournal) {
        guard let properURL = URL(string: url) else { return }
        let dataTask = URLSession.shared.dataTask(with: properURL) { data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                
                self.connectionRetries += 1
                return
            }
            CoreDataImagesManager.shared.updateImage(name: imageName, data: data)
            
            DispatchQueue.main.async {
                self.updateRaidInstanceBackground(for: instance, with: data)
            }
            
        }
        dataTask.resume()
    }
    
    
    func updateRaidInstanceBackground(for instance: InstanceJournal, with data: Data) {
        guard let indexToUpdate = raids.firstIndex(where: { (raidInstance) -> Bool in
            return raidInstance.id == instance.id && raidInstance.expansion.id == instance.expansion.id
        }) else { return }
        raids[indexToUpdate].background = data
    }
    
    func updateRaidCombinedBackground(for raid: CombinedRaidWithEncounters, with data: Data) {
        guard let indexToUpdate = raids.firstIndex(where: { (raidInstance) -> Bool in
            return raidInstance.id == raid.id && raidInstance.expansion.id == raid.expansion.id
        }) else { return }
        raids[indexToUpdate].background = data
    }
}
