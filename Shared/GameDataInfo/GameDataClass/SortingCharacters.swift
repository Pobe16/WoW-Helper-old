//
//  SortingCharacters.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    func addOrderToCharacters(_ downloadedCharacters: [CharacterInProfile]) {
        var accountCharacters: [CharacterInProfile] = []
        var accountIgnoredCharacters: [CharacterInProfile] = []
        
        for var character in downloadedCharacters {
            let currentCharacterOrder = UserDefaults.standard.integer(forKey: "\(UserDefaultsKeys.characterOrder)\(character.name)\(character.id)\(character.realm.slug)")
            character.order = currentCharacterOrder
            if character.order! > 999 {
                accountIgnoredCharacters.append(character)
            } else {
                accountCharacters.append(character)
            }
        }
        
        accountCharacters.sort { (lhs, rhs) -> Bool in
            lhs.order! < rhs.order!
        }
        
        accountIgnoredCharacters.sort { (lhs, rhs) -> Bool in
            lhs.name < rhs.name
        }
        
        if accountCharacters.count > 0 {
            for i in 1...accountCharacters.count - 1 {
                if accountCharacters[i].order == 0 {
                    accountCharacters[i].order = i
                    let character = accountCharacters[i]
                    UserDefaults.standard.setValue(i, forKey: "\(UserDefaultsKeys.characterOrder)\(character.name)\(character.id)\(character.realm.slug)")
                }
            }
        }
        
        DispatchQueue.main.async { [self] in
            withAnimation {
                characters = accountCharacters
            }
            
            ignoredCharacters = accountIgnoredCharacters
            
            charactersForRaidEncounters.append(contentsOf: accountCharacters.filter({ (character) -> Bool in
                character.level >= 30
            }))
            
            actualItemsToDownload += charactersForRaidEncounters.count
            print("finished loading characters")
            print("loaded \(characters.count) characters, including \(charactersForRaidEncounters.count) in raiding level")
            prepareForAvatarSaving()
            loadAccountMounts()
        }
    }
    
    func changeCharactersOrder(from source: IndexSet, to destination: Int) {
        characters.move(fromOffsets: source, toOffset: destination)
        
        rewriteOrders()
        
        DispatchQueue.main.async { [self] in
            withAnimation {
                characterRaidEncounters.sort { characterRaidEncountersSorting(lhs: $0, rhs: $1) }
            }
        }
    }
    
    func rewriteOrders(){
        characters.forEach { (item) in
            let newOrder = characters.firstIndex(of: item)
            if newOrder != nil {
                characters[newOrder!].order = newOrder!
            }
            UserDefaults.standard.setValue(newOrder!, forKey: "\(UserDefaultsKeys.characterOrder)\(item.name)\(item.id)\(item.realm.slug)")
        }
    }
    
    func ignoreCharacter(at offsets: IndexSet) {
        var characterToIgnore = characters.remove(at: offsets.first!)
        characterToIgnore.order! += 1050
        
        ignoredCharacters.append(characterToIgnore)
        
        UserDefaults.standard.setValue(characterToIgnore.order!, forKey: "\(UserDefaultsKeys.characterOrder)\(characterToIgnore.name)\(characterToIgnore.id)\(characterToIgnore.realm.slug)")
        DispatchQueue.main.async { [self] in
            withAnimation {
                characterRaidEncounters.removeAll { (characterEncounters) -> Bool in
                    characterEncounters.character.name == characterToIgnore.name &&
                    characterEncounters.character.id == characterToIgnore.id &&
                    characterEncounters.character.realm.slug == characterToIgnore.realm.slug
                }
            }
            rewriteOrders()
        }
    }
    
    func unIgnoreCharacter(_ character: CharacterInProfile) {
        let index = ignoredCharacters.firstIndex(of: character) ?? 0
        var characterToPutBack = ignoredCharacters[index]
        characterToPutBack.order! -= 1000
        
        DispatchQueue.main.async { [self] in
            withAnimation {
                ignoredCharacters.remove(at: index)
                characters.append(characterToPutBack)
            }
            rewriteOrders()
            UserDefaults.standard.setValue(characterToPutBack.order!, forKey: "\(UserDefaultsKeys.characterOrder)\(characterToPutBack.name)\(characterToPutBack.id)\(characterToPutBack.realm.slug)")
            if characterToPutBack.level >= 30 {
                reloadCharacterRaidEncounters(for: characterToPutBack)
            }
        }
        
    }
}
