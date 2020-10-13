//
//  ExpansionJournal.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import Foundation

struct ExpansionJournal: Codable, Hashable, Identifiable, Comparable {
    static func < (lhs: ExpansionJournal, rhs: ExpansionJournal) -> Bool {
        return lhs.id < rhs.id
    }
    
    let id: Int
    let name: String
    let dungeons: [InstanceIndex]?
    let raids: [InstanceIndex]?
    let worldBosses: [EncounterIndex]?
}

struct InstanceIndex: Codable, Hashable, Identifiable {
    let key: LinkStub
    let id: Int
    let name: String
}

struct EncounterIndex: Codable, Hashable, Identifiable {
    let key: LinkStub
    let id: Int
    let name: String
}
