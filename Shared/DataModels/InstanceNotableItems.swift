//
//  InstanceNotableItems.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 16/10/2020.
//

import Foundation

enum ItemQualityName: String, Codable {
    case poor
    case common
    case uncommon
    case rare
    case epic
    case legendary
    case heirloom
    case artifact
}

struct InstanceNotableItems: Hashable, Equatable {
    let id: Int
    let mounts: [QualityItemStub]
    let pets: [QualityItemStub]
}

struct CharacterInstanceNotableItems: Hashable, Codable {
    let characterID: Int
    let characterName: String
    let characterRealmSlug: String
    let raidID: Int
    let mounts: [QualityItemStub]
    let pets: [QualityItemStub]
}

struct QualityItemStub: Hashable, Codable, Equatable {
    static func == (
        lhs: QualityItemStub,
        rhs: QualityItemStub
    ) -> Bool {
        lhs.id == rhs.id
    }
    let name: LocalizedName
    let id: Int
    let quality: ItemQualityName
}

struct QualityItemStubWithIconAddress: Hashable, Codable, Equatable {
    static func == (
        lhs: QualityItemStubWithIconAddress,
        rhs: QualityItemStubWithIconAddress
    ) -> Bool {
        lhs.id == rhs.id
    }
    let name: LocalizedName
    let id: Int
    let quality: ItemQualityName
    let iconURI: String
}
