//
//  RaidJournal.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 23/08/2020.
//

import Foundation

struct InstanceJournal: Decodable, Hashable, Identifiable, Comparable {
    static func < (lhs: InstanceJournal, rhs: InstanceJournal) -> Bool {
        if lhs.expansion.id == rhs.expansion.id {
            return lhs.id < rhs.id
        } else {
            return lhs.expansion.id < rhs.expansion.id
        }
    }
    let id: Int
    let name: String
    let map: InstanceMapIndex
    let description: String
    let encounters: [EncounterIndex]
    let expansion: ExpansionIndex
    let location: LocationIndex?
    let modes: [RaidModes]
    let media: InstanceMedia
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

struct RaidModes: Decodable, Hashable {
    let mode: RaidModesNames
    let players: Int
    let isTracked: Bool
}

struct RaidModesNames: Decodable, Hashable {
    let type: String
    let name: String
}

struct InstanceMedia: Decodable, Hashable, Identifiable {
    let key: LinkStub
    let id: Int
}

struct InstanceCategory: Decodable, Hashable {
    let type: String
}
