//
//  IntentHandler.swift
//  CharacterRaidIntent
//
//  Created by Mikolaj Lukasik on 25/11/2020.
//

import Intents
import SwiftUI

class IntentHandler: INExtension, ConfigurationIntentHandling {
    @AppStorage(UserDefaultsKeys.characterSuggestions, store: UserDefaults(suiteName: UserDefaultsKeys.appUserGroup))
    var characterSuggestionsData: Data = Data()
    
    func provideCharacterOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<WoWCharacter>?, Error?) -> Void) {
        print("starting collection")
        var loadedCharacters: [CharacterForIntent] = []
        do {
            let charactersFromUserDefaults = try JSONDecoder().decode([CharacterForIntent].self, from: characterSuggestionsData)
            print(charactersFromUserDefaults)
            loadedCharacters.append(contentsOf: charactersFromUserDefaults)
            
            
        } catch {
            print(error)
        }
        let finalCharacters: [WoWCharacter] = loadedCharacters.map { character in
            let wowCharacter = WoWCharacter(
                identifier: "\(character.characterName)-\(character.characterRealmSlug)",
                display: "\(character.characterName), \(character.characterRealmName), lvl \(character.characterLevel)"
            )
            wowCharacter.characterID        = NSNumber(value: character.characterID)
            wowCharacter.characterName      = character.characterName
            wowCharacter.characterLevel     = NSNumber(value: character.characterLevel)
            wowCharacter.characterRealm     = character.characterRealmSlug
            wowCharacter.characterFaction   = character.characterFaction.rawValue
            wowCharacter.characterAvatarURI = character.characterAvatarURI
            
            return wowCharacter
        }
        
        let collection = INObjectCollection(items: finalCharacters)
        
        completion(collection, nil)
        
    }
    
    func defaultCharacter(for intent: ConfigurationIntent) -> WoWCharacter? {
        print("starting default")
        
        guard let charactersFromUserDefaults = try? JSONDecoder().decode([CharacterForIntent].self, from: characterSuggestionsData) else { return nil }
        
        guard let firstCharacter = charactersFromUserDefaults.first else { return nil }
        
        let primaryCharacter = WoWCharacter(
            identifier: "\(firstCharacter.characterName)-\(firstCharacter.characterRealmSlug)",
            display: "\(firstCharacter.characterName), \(firstCharacter.characterRealmName), lvl \(firstCharacter.characterLevel)"
        )
        primaryCharacter.characterID        = NSNumber(value: firstCharacter.characterID)
        primaryCharacter.characterName      = firstCharacter.characterName
        primaryCharacter.characterLevel     = NSNumber(value: firstCharacter.characterLevel)
        primaryCharacter.characterRealm     = firstCharacter.characterRealmSlug
        primaryCharacter.characterFaction   = firstCharacter.characterFaction.rawValue
        primaryCharacter.characterAvatarURI = firstCharacter.characterAvatarURI
        
        return primaryCharacter
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
