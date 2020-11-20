//
//  SavingAvatars.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    
    func prepareForAvatarSaving(){
        for character in characters {
            loadCharacterMediaData(for: character)
        }
        for ignoredCharacter in ignoredCharacters {
            loadCharacterMediaData(for: ignoredCharacter)
        }
    }
    
    private func loadCharacterMediaData(for character: CharacterInProfile) {
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let encodedName = character.name.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let requestUrlAPIFragment = "/profile/wow/character" +
                                    "/\(character.realm.slug)" +
                                    "/\(encodedName ?? character.name.lowercased())" +
                                    "/character-media"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? APIRegionHostList.Europe
        
        guard let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        ) else {
            prepareNonExistingMedia(for: character)
            return
        }
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
            
                self.prepareNonExistingMedia(for: character)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let dataResponse = try decoder.decode(CharacterMedia.self, from: data)
                
                
                self.getAvatarFromMedia(dataResponse, for: character)
                
            } catch {
                self.prepareNonExistingMedia(for: character)
                print(error)
            }
        }
        task.resume()
    }
    
    private func getShortAvatar(from characterMedia: CharacterMedia) -> String? {
        guard let mediaAssets = characterMedia.assets else {
            guard let avatarUrl = characterMedia.avatarUrl else {
                return nil
            }
            return avatarUrl
        }
        guard let avatarUrl = mediaAssets.first(where: { (asset) -> Bool in
            asset.key == "avatar"
        }) else { return nil}
        return avatarUrl.key
    }
    
    func getAvatarFromMedia(_ media: CharacterMedia, for character: CharacterInProfile) {
        guard let shortAvatarAddress = getShortAvatar(from: media),
              let avatarURL = URL(string: shortAvatarAddress + "?alt=/shadow/avatar/\(character.playableRace.id)-\(character.gender.type == .male ? 0 : 1)")
              else {
            prepareNonExistingMedia(for: character)
            return
        }
        
        let encodedName = character.name.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let identifiableImageName = "\(UserDefaultsKeys.characterAvatar)-\(encodedName ?? character.name.lowercased())-\(character.realm.slug)"
        
        guard let storedImage = CoreDataImagesManager.shared.fetchImage(withName: identifiableImageName, maximumAgeInDays: 10) else {
            
            let dataTask = URLSession.shared.dataTask(with: avatarURL) { data, response, error in
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data else {
                    
                    self.prepareNonExistingMedia(for: character)
                    return
                    
                }
                
                CoreDataImagesManager.shared.updateImage(name: identifiableImageName, data: data)
                
                DispatchQueue.main.async {
                    self.updateCharacterAvatar(for: character, with: data)
                }
            }
            dataTask.resume()
            return
        }
        
        guard let characterData = storedImage.data else { return }
        
        DispatchQueue.main.async {
            self.updateCharacterAvatar(for: character, with: characterData)
        }
    }
    
    private func prepareNonExistingMedia(for character: CharacterInProfile) {
        guard let shadow =
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
        """.data(using: .utf8) else { return }
        
        let characterMedia = try! JSONDecoder().decode(CharacterMedia.self, from: shadow)
        
        getAvatarFromMedia(characterMedia, for: character)
    }
    
    private func characterIsIgnored(_ character: CharacterInProfile) -> Bool {
        if ignoredCharacters.isEmpty { return false }
        if ignoredCharacters.contains(where: { (ignoredCharacter) -> Bool in
            ignoredCharacter.id == character.id &&
            ignoredCharacter.name == character.name &&
            ignoredCharacter.realm.id == character.realm.id
        }) { return true }
        return false
    }
    
    func updateCharacterAvatar(for character: CharacterInProfile, with data: Data) {
              
        if !characterIsIgnored(character) {
    
            guard let indexToUpdate = characters.firstIndex(where: { (charProfile) -> Bool in
                return charProfile.id == character.id && charProfile.realm.id == character.realm.id
            }) else { return }
            DispatchQueue.main.async {
                withAnimation {
                    self.characters[indexToUpdate].avatar = data
                }
            }
            
        }
    }
       
}
