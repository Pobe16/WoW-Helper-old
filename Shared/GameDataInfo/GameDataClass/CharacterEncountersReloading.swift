//
//  CharacterEncountersReloading.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    func reloadCharacterRaidEncounters(for character: CharacterInProfile) {
        reloadFromCDAllowed = false
        
        DispatchQueue.main.async {
            self.characterRaidEncounters.removeAll { (encountersCharacter) -> Bool in
                encountersCharacter.character.id == character.id &&
                encountersCharacter.character.name == character.name &&
                encountersCharacter.character.realm.slug == character.realm.slug
            }
            self.charactersForRaidEncounters.append(character)
            self.loadCharacterRaidEncounters()
        }
    }
    
    func characterRaidEncountersSorting(lhs: CharacterRaidEncounters, rhs: CharacterRaidEncounters) -> Bool {
        let lhsCharacter = characters.first { (baseCharacter) -> Bool in
            lhs.character.id == baseCharacter.id
        }
        let rhsCharacter = characters.first { (baseCharacter) -> Bool in
            rhs.character.id == baseCharacter.id
        }
        return lhsCharacter!.order! < rhsCharacter!.order!
    }
    
}
