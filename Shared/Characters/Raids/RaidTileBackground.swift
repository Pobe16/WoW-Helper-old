//
//  RaidTileBackground.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct RaidTileBackground: View {
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    
    @State var timeRetries = 0
    @State var connectionRetries = 0
    
    @State var raid: CombinedRaidWithEncounters
    
    var body: some View {
        if raid.background == nil {
            Image("raid_placeholder")
                .resizable()
                .scaledToFill()
                .onAppear(perform: {
                    checkForStoredImage()
                })
        } else {
            #if os(iOS)
            Image(uiImage: UIImage(data: raid.background!)!)
                .resizable()
                .scaledToFill()
            #elseif os(macOS)
            Image(nsImage: NSImage(data: raid.background!)!)
                .resizable()
                .scaledToFill()
            #endif
        }
    }
    
    func checkForStoredImage() {
        guard timeRetries < 2, connectionRetries < 2 else { return }
        guard raid.background == nil else { return }
        let instanceNameTransformed = raid.raidName.lowercased().replacingOccurrences(of: " ", with: "-")
        let nameForImage = "\(instanceNameTransformed)-\(raid.id)-tile-background"
        
        guard let storedImage = CoreDataImagesManager.shared.fetchImage(withName: nameForImage, maximumAgeInDays: 100) else {
            loadMediaData(saveAs: nameForImage)
            return
        }
        DispatchQueue.main.async {
            withAnimation {
                raid.background = storedImage.data
            }
            gameData.updateRaidCombinedBackground(for: raid, with: storedImage.data!)
        }
        
    }
    
    func loadMediaData(saveAs imageName: String) {
        
        let requestUrlJournalMedia = raid.media.key.href
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
                    timeRetries += 1
                    print("retrying in 1s")
                    loadMediaData(saveAs: imageName)
                }
                return
            }
            
            decodeMedia(data, fromURL: fullRequestURL, saveImageAs: imageName)
                
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task.resume()
        
    }
    
    func decodeMedia(_ data: Data, fromURL url: URL? = nil, saveImageAs imageName: String) {
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
            
            downloadNewImage(from: backgroundURL, saveImageAs: imageName)
            
        } catch {
            print(error)
        }
    }
    
    func downloadNewImage(from url: String, saveImageAs imageName: String) {
        guard let properURL = URL(string: url) else { return }
        let dataTask = URLSession.shared.dataTask(with: properURL) { data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                connectionRetries += 1
                return
            }
            CoreDataImagesManager.shared.updateImage(name: imageName, data: data)
            
            DispatchQueue.main.async {
                withAnimation {
                    raid.background = data
                }
                gameData.updateRaidCombinedBackground(for: raid, with: data)
            }
            
        }
        dataTask.resume()
    }
}
