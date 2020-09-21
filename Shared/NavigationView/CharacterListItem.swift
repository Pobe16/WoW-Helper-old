//
//  CharacterListItem.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 14/08/2020.
//

import SwiftUI

struct CharacterListItem: View {
    @EnvironmentObject var authorization: Authentication
    @State var characterMedia: CharacterMedia?
    let character: CharacterInProfile
    @State var characterImageData: Data? = nil
    var body: some View {
        HStack{
            if characterImageData == nil {
                Image(systemName: "arrow.counterclockwise.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63, height: 63)
                    .cornerRadius(15, antialiased: true)
            } else {
                #if os(iOS)
                Image(uiImage: UIImage(data: characterImageData!)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63, height: 63)
                    .cornerRadius(15, antialiased: true)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("faction\(character.faction.name)"), lineWidth: 2)
                    )
                #else
                Image(nsImage: NSImage(data: characterImageData!)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63, height: 63)
                    .cornerRadius(15, antialiased: true)
                #endif
            }
            Text("\(character.name) lvl: \(character.level)")
            
        }
        .listRowBackground(Color.red)
        .onAppear(perform: {
            loadMediaData()
        })
    }
    
    fileprivate func prepareNonExistingMedia() {
        let shadow =
        """
        {
            "avatarUrl": "https://render-us.worldofwarcraft.com/shadow/avatar/\(character.playableRace.id)-\(character.gender.type == "MALE" ? 0 : 1).jpg"
        }
        """.data(using: .utf8)!
        
        characterMedia = try! JSONDecoder().decode(CharacterMedia.self, from: shadow)
        
        loadCharacterAvatar()
    }
    
    fileprivate func loadMediaData() {
        
        let characterCacheID = NSString(string: "\(character.name)-\(character.id)")
        if let cachedData = StoredCache.CharacterMedia.object(forKey: characterCacheID) {
            characterMedia = cachedData
            loadCharacterAvatar()
        } else {
            let requestUrlAPIHost = UserDefaults.standard.object(forKey: "APIRegionHost") as? String ?? APIRegionHostList.Europe
            let requestUrlAPIFragment = "/profile/wow/character" +
                                        "/\(character.realm.slug)" +
                                        "/\(character.name.lowercased())" +
                                        "/character-media"
            let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: "loginRegion")]
            let requestAPINamespace = "profile-\(regionShortCode)"
            let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? APIRegionHostList.Europe
            
            let fullRequestURL = URL(string:
                                        requestUrlAPIHost +
                                        requestUrlAPIFragment +
                                        "?namespace=\(requestAPINamespace)" +
                                        "&locale=\(requestLocale)" +
                                        "&access_token=\(authorization.oauth2.accessToken ?? "")"
            )!
            let req = authorization.oauth2.request(forURL: fullRequestURL)
//            print(fullRequestURL)
            let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data else {
                
                    prepareNonExistingMedia()
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let dataResponse = try decoder.decode(CharacterMedia.self, from: data)
                    
                    StoredCache.CharacterMedia.setObject(dataResponse, forKey: characterCacheID)
                    characterMedia = dataResponse
                    
                    loadCharacterAvatar()
                    
                } catch {
                    print(error)
                }
                    
                    
                
                if let error = error {
                    // something went wrong, check the error
                    print("error")
                    print(error.localizedDescription)
                }
            }
            task.resume()
        }
        
    }
    
    fileprivate func loadCharacterAvatar() {
        guard let characterMedia = characterMedia else {
            return
        }
        guard let avatarURL = URL(string: characterMedia.avatarUrl + "?alt=/shadow/avatar/\(character.playableRace.id)-\(character.gender.type == "MALE" ? 0 : 1)") else {
            return
        }
        
        guard let storedImage = CoreDataImagesManager.shared.fetchImage(withName: characterMedia.avatarUrl, maximumAgeInDays: 10) else {
            
            let dataTask = URLSession.shared.dataTask(with: avatarURL) { data, response, error in
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data else {
                    return
                    
                }
                
                CoreDataImagesManager.shared.updateImage(name: characterMedia.avatarUrl, data: data)
                characterImageData = data
            }
            dataTask.resume()
            return
        }
        
        characterImageData = storedImage.data
    }
}

struct CharacterListItem_Previews: PreviewProvider {
    static var previews: some View {
        CharacterListItem(character: placeholders.characterInProfile)
    }
}
