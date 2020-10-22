//
//  SwiftUIView.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 07/10/2020.
//

import SwiftUI

struct CharacterImage: View {
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    @State var characterMedia: CharacterMedia?
    @State var character: CharacterInProfile
    
    @State var frameSize: CGFloat = 63
    
    var body: some View {
        if character.avatar == nil {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(width: frameSize, height: frameSize)
                .cornerRadius(15, antialiased: true)
                .onAppear(perform: {
                    loadMediaData()
                })
        } else {
            #if os(iOS)
            Image(uiImage: UIImage(data: character.avatar!)!)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .cornerRadius(15, antialiased: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color("faction\(character.faction.type.rawValue)"), lineWidth: 2)
                )
            #else
            Image(nsImage: NSImage(data: character.avatar!)!)
                .resizable()
                .scaledToFit()
                .frame(width: frameSize, height: frameSize)
                .cornerRadius(15, antialiased: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color("faction\(character.faction.type.rawValue)"), lineWidth: 2)
                )
            #endif
        }
    }
    fileprivate func prepareNonExistingMedia() {
        let shadow =
        """
        {
        "assets":
            [
                {
                    "key": "avatar",
                    "value": "https://render-us.worldofwarcraft.com/shadow/avatar/\(character.playableRace.id)-\(character.gender.type == .male ? 0 : 1).jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        characterMedia = try! JSONDecoder().decode(CharacterMedia.self, from: shadow)
        
        loadCharacterAvatar()
    }
    
    fileprivate func loadMediaData() {
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/wow/character" +
                                    "/\(character.realm.slug)" +
                                    "/\(character.name.lowercased())" +
                                    "/character-media"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? APIRegionHostList.Europe
        
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
            
                prepareNonExistingMedia()
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let dataResponse = try decoder.decode(CharacterMedia.self, from: data)
                characterMedia = dataResponse
                
                loadCharacterAvatar()
                
            } catch {
                prepareNonExistingMedia()
                print(error)
            }
                
                
            
            if let error = error {
                prepareNonExistingMedia()
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    fileprivate func getShortAvatar() -> String? {
        if characterMedia?.assets != nil {
            guard let avatarAsset = characterMedia?.assets?.first(where: { (asset) -> Bool in
                asset.key == "avatar"
            }) else { return nil }
            return avatarAsset.value
        } else if characterMedia?.avatarUrl != nil {
            return characterMedia?.avatarUrl!
        }
        return nil
    }
    
    fileprivate func loadCharacterAvatar() {
        guard let shortAvatarAddress = getShortAvatar(),
              let avatarURL = URL(string: shortAvatarAddress + "?alt=/shadow/avatar/\(character.playableRace.id)-\(character.gender.type == .male ? 0 : 1)")
              else {
            prepareNonExistingMedia()
            return
        }
        guard let storedImage = CoreDataImagesManager.shared.fetchImage(withName: shortAvatarAddress, maximumAgeInDays: 10) else {
            
            let dataTask = URLSession.shared.dataTask(with: avatarURL) { data, response, error in
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data else {
                    
                    prepareNonExistingMedia()
                    return
                    
                }
                
                CoreDataImagesManager.shared.updateImage(name: shortAvatarAddress, data: data)
                character.avatar = data
                DispatchQueue.main.async {
                    gameData.updateCharacterAvatar(for: character, with: data)
                }
            }
            dataTask.resume()
            return
        }
        
        character.avatar = storedImage.data!
        DispatchQueue.main.async {
            gameData.updateCharacterAvatar(for: character, with: storedImage.data!)
        }
    }
}

struct CharacterImage_Previews: PreviewProvider {
    static var previews: some View {
        CharacterImage(character: placeholders.characterInProfile)
    }
}
