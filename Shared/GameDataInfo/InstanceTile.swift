//
//  InstanceTile.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 23/08/2020.
//

import SwiftUI

struct InstanceTile: View {
    @EnvironmentObject var authorization: Authentication
    @Environment(\.colorScheme) var colorScheme
    @State var instance: InstanceJournal? = nil
    @State var category: String
    @State var imageData: Data? = nil
    
    @State var timeRetries: Int = 0
    @State var connectionRetries: Int = 0
    
    var body: some View {
        ZStack{
            if imageData == nil {
                Image("\(category)_placeholder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 150)
                    .cornerRadius(15, antialiased: true)
            } else {
                #if os(iOS)
                Image(uiImage: UIImage(data: imageData!)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 150)
                #elseif os(macOS)
                Image(nsImage: NSImage(data: imageData!)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 150)
                #endif
            }
            VStack(alignment: .leading){
                Spacer()
                Spacer()
                HStack{
                    Spacer()
                    Text("Bosses: \(instance?.encounters.count ?? 0)")
                        .padding(.vertical, 4)
                    Spacer()
                }
                .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.8))
//                    .cornerRadius(15)
                Spacer()
                HStack{
                    Spacer()
                    Text(instance?.name ?? "Loading…")
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.vertical, 4)
                    Spacer()
                }
                .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.8))
                    
                    
                
            }
            .frame(width: imageData == nil ? 200 : 300, height: 150)
        }
        .cornerRadius(15, antialiased: true)
        .onAppear(perform: {
            
            checkForStoredImage()
            
        })
    }
    
//    func deleteAllImages() {
//        let allImages = CoreDataImagesManager.shared.fetchImages()
//        allImages?.forEach({ (imageObj) in
//            CoreDataImagesManager.shared.deleteImage(image: imageObj)
//        })
//    }
    
    func checkForStoredImage() {
        guard timeRetries < 2, connectionRetries < 2 else { return }
        guard let instance = instance else { return }
        let instanceNameTransformed = instance.name.lowercased().replacingOccurrences(of: " ", with: "-")
        let nameForImage = "\(instanceNameTransformed)-\(instance.id)-tile-background"
        
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
        
        guard let instance = instance else { return }
        
        let requestUrlJournalMedia = instance.media.key.href
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

struct InstanceTile_Previews: PreviewProvider {
    static var previews: some View {
        InstanceTile(category: "dungeon")
            .previewLayout(.fixed(width: 250, height: 200))
            .padding()
            .previewDisplayName("One Tile")
    }
}
