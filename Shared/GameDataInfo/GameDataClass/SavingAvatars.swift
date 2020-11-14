//
//  SavingAvatars.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    
    func updateCharacterAvatar(for character: CharacterInProfile, with data: Data) {
        guard let indexToUpdate = characters.firstIndex(where: { (charProfile) -> Bool in
            return charProfile.id == character.id && charProfile.realm.id == character.realm.id
        }) else { return }
        characters[indexToUpdate].avatar = data
    }
    
}
