//
//  RaidTileBackground.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct RaidTileBackground: View {
    @EnvironmentObject var authorization: Authentication
    
    @State var timeRetries = 0
    @State var connectionRetries = 0
    
    @State var imageData: Data? = nil
    
    let name: String
    let id: Int
    let mediaUrl: String
    
    var body: some View {
        if imageData == nil {
            Image("raid_placeholder")
                .resizable()
                .scaledToFill()
                .onAppear(perform: {
                    checkForStoredImage()
                })
        } else {
            #if os(iOS)
            Image(uiImage: UIImage(data: imageData!)!)
                .resizable()
                .scaledToFill()
            #elseif os(macOS)
            Image(nsImage: NSImage(data: imageData!)!)
                .resizable()
                .scaledToFill()
            #endif
        }
    }
    
    func checkForStoredImage() {
        guard timeRetries < 2, connectionRetries < 2 else { return }
        guard imageData == nil else { return }
        let instanceNameTransformed = name.lowercased().replacingOccurrences(of: " ", with: "-")
        let nameForImage = "\(instanceNameTransformed)-\(id)-tile-background"
        
        guard let storedImage = CoreDataImagesManager.shared.fetchImage(withName: nameForImage, maximumAgeInDays: 100) else {
            loadMediaData(saveAs: nameForImage)
            return
        }
        DispatchQueue.main.async {
            withAnimation {
                
                imageData = storedImage.data
            }
        }
        
    }
    
    func loadMediaData(saveAs imageName: String) {
        
        let requestUrlJournalMedia = mediaUrl
        let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? APIRegionHostList.Europe
        
        let fullRequestURL = URL(string:
                                    requestUrlJournalMedia +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2?.accessToken ?? "")"
        )!
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
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
        task?.resume()
        
    }
    
    func decodeMedia(_ data: Data, fromURL url: URL? = nil, saveImageAs imageName: String) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(InstanceMedia.self, from: data)
            
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
                    imageData = data
                }
            }
            
        }
        dataTask.resume()
    }
}

struct RaidTileBackground_Previews: PreviewProvider {
    static var previews: some View {
        RaidTileBackground(name: "mm", id: 1, mediaUrl: "m")
    }
}
