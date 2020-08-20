//
//  GameData.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 20/08/2020.
//

import Foundation

class GameData: ObservableObject {
    @Published var expansions: [ExpansionJournal]
    @Published var raids: [Any]
    @Published var dungeons: [Any]
    @Published var encounters: [Any]
    
    init() {
        expansions      = []
        raids           = []
        dungeons        = []
        encounters      = []
    }
}
