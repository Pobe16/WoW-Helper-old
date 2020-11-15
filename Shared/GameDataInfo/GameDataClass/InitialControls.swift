//
//  InitialControls.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 14/11/2020.
//

import Foundation
import SwiftUI

extension GameData {
    
    func hardReloadGameData(authorizedBy auth: Authentication) {
        guard loadingAllowed else { return }
        reloadFromCDAllowed = false
        authorization = auth
        deleteDataBeforeUpdating()
    }
    
    func deleteDataBeforeUpdating() {
        DispatchQueue.main.async {
            self.expansionsStubs.removeAll()
            self.raidsStubs.removeAll()
            self.raidEncountersStubs.removeAll()
            self.raidEncounters.removeAll()
            self.charactersForRaidEncounters.removeAll()
            
            self.downloadedItems = 1
            self.actualItemsToDownload = 0
            
            withAnimation {
                self.characters.removeAll()
                self.expansions.removeAll()
                self.raids.removeAll()
                self.characterRaidEncounters.removeAll()
            }
            self.loadCharacters()
        }
    }
    
    func loadGameData(authorizedBy auth: Authentication) {
        guard characters.count == 0 && loadingAllowed else { return }
        reloadFromCDAllowed = true
        authorization = auth
        
        if downloadedItems > 1 { downloadedItems = 1 }
        if actualItemsToDownload > 0 { actualItemsToDownload = 0}
        
        loadCharacters()
    }
    
}
