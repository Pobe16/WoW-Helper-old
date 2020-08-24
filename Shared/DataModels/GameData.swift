//
//  GameData.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 20/08/2020.
//

import Foundation
import SwiftUI

class GameData: ObservableObject {
    @EnvironmentObject var authorization: Authentication
    
    @Published var loadingAllowed: Bool                     = true
    
    @Published var expansionsStubs: [ExpansionIndex]        = []
    @Published var expansions: [ExpansionJournal]           = []
    
    @Published var raidsStubs: [InstanceIndex]              = []
    @Published var raids: [InstanceJournal]                 = []
    
    @Published var dungeonsStubs: [InstanceIndex]           = []
    @Published var dungeons: [InstanceJournal]              = []
    
//    @Published var encountersStubs: [EncounterIndex]        = []
//    @Published var encounters: [Any]                        = []
    
    let estimatedItemsToDownload: Int                       = 150
    @Published var actualItemsToDownload: Int               = 0
    
    @Published var downloadedItems: Int                     = 1
}
