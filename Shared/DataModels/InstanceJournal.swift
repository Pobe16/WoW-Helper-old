//
//  RaidJournal.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 23/08/2020.
//

import Foundation

struct InstanceJournal: Decodable, Hashable, Identifiable, Comparable, Equatable {
    static func < (lhs: InstanceJournal, rhs: InstanceJournal) -> Bool {
        if lhs.expansion.id == rhs.expansion.id {
            return lhs.id < rhs.id
        } else {
            return lhs.expansion.id < rhs.expansion.id
        }
    }
    static func == (lhs: InstanceJournal, rhs: InstanceJournal) -> Bool {
        if lhs.id == rhs.id && lhs.name == rhs.name {
            return true
        } else {
            return false
        }
    }
    
    let id: Int
    let name: String
    let map: InstanceMapIndex
    let description: String?
    let encounters: [EncounterIndex]
    let expansion: ExpansionIndex
    let location: LocationIndex?
    let modes: [InstanceModes]
    let media: InstanceMediaStub
    let minimumLevel: Int
    let category: InstanceCategory
}

struct InstanceMapIndex: Decodable, Hashable, Identifiable {
    let name: String
    let id: Int
}

struct LocationIndex: Decodable, Hashable, Identifiable {
    let name: String
    let id: Int
}

struct InstanceModes: Decodable, Hashable {
    let mode: InstanceModesNames
    let players: Int
    let isTracked: Bool
}

struct InstanceModesNames: Decodable, Hashable {
    let type: String
    let name: String
}

struct InstanceMediaStub: Decodable, Hashable, Identifiable {
    let key: LinkStub
    let id: Int
}

struct InstanceCategory: Decodable, Hashable {
    let type: String
}
