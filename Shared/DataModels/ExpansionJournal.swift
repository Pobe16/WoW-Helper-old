//
//  ExpansionJournal.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import Foundation

struct ExpansionJournal: Decodable, Hashable, Identifiable, Comparable {
    static func < (lhs: ExpansionJournal, rhs: ExpansionJournal) -> Bool {
        return lhs.id < rhs.id
    }
    
    let id: Int
    let name: String
    let dungeons: [InstanceIndex]?
    let raids: [InstanceIndex]?
    let worldBosses: [EncounterIndex]?
}

struct InstanceIndex: Decodable, Hashable, Identifiable {
    let key: LinkStub
    let id: Int
    let name: String
}

struct EncounterIndex: Decodable, Hashable, Identifiable {
    let key: LinkStub
    let id: Int
    let name: String
}
