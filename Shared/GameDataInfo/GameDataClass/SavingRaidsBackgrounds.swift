//
//  SavingRaidsBackgrounds.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    
    func updateRaidInstanceBackground(for instance: InstanceJournal, with data: Data) {
        guard let indexToUpdate = raids.firstIndex(where: { (raidInstance) -> Bool in
            return raidInstance.id == instance.id && raidInstance.expansion.id == instance.expansion.id
        }) else { return }
        raids[indexToUpdate].background = data
    }
    
    func updateRaidCombinedBackground(for raid: CombinedRaidWithEncounters, with data: Data) {
        guard let indexToUpdate = raids.firstIndex(where: { (raidInstance) -> Bool in
            return raidInstance.id == raid.id && raidInstance.expansion.id == raid.expansion.id
        }) else { return }
        raids[indexToUpdate].background = data
    }
}
