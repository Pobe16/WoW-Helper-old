//
//  RaidJournal.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 23/08/2020.
//

import Foundation

struct InstanceJournal: Codable, Hashable, Identifiable, Comparable, Equatable {
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
    var background: Data?
    let id: Int
    let name: String
    let map: InstanceMapIndex
    let description: String?
    let encounters: [EncounterIndex]
    let expansion: ExpansionIndex
//    let location: LocationIndex?
    let modes: [InstanceMode]
    let media: InstanceMediaStub
    let minimumLevel: Int
    let category: InstanceCategory
}

struct InstanceMapIndex: Codable, Hashable, Identifiable {
    let name: String
    let id: Int
}

//struct LocationIndex: Codable, Hashable, Identifiable {
//    let name: String
//    let id: Int
//}

struct InstanceMode: Codable, Hashable {
    let mode: InstanceModeName
    let players: Int
    let isTracked: Bool
}

struct InstanceModeName: Codable, Hashable {
    let type: InstanceModeType
    let name: String
}

enum InstanceModeType: String, Codable, Hashable {    
    case lfr            = "LFR"
    case legacy10       = "LEGACY_10_MAN"
    case legacy25       = "LEGACY_25_MAN"
    case normal         = "NORMAL"
    case legacy10Hero   = "LEGACY_10_MAN_HEROIC"
    case legacy25Hero   = "LEGACY_25_MAN_HEROIC"
    case heroic         = "HEROIC"
    case mythic         = "MYTHIC"
    case mythicKeystone = "MYTHIC_KEYSTONE"
    
}

struct InstanceMediaStub: Codable, Hashable, Identifiable {
    let key: LinkStub
    let id: Int
}

struct InstanceCategory: Codable, Hashable {
    let type: InstanceCategoryType
}

enum InstanceCategoryType: String, Codable {
    case raid           = "RAID"
    case dungeon        = "DUNGEON"
    case event          = "EVENT"
}

