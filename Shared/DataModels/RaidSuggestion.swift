//
//  RaidSuggestion.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 15/11/2020.
//

import Foundation

struct RaidsSuggestedForCharacter: Codable, Hashable, Identifiable {
    var id: String { characterName + characterRealmSlug }
    let characterID: Int
    let characterName: String
    let characterLevel: Int
    let characterRealmSlug: String
    let characterAvatarURI: String
    let characterFaction: FactionType
    let raids: [RaidSuggestion]
}

struct CharacterForIntent: Codable, Hashable, Identifiable {
    var id: String { characterName + characterRealmSlug }
    let characterID: Int
    let characterName: String
    let characterLevel: Int
    let characterRealmSlug: String
    let characterRealmName: String
    let characterAvatarURI: String
    let characterFaction: FactionType
}

struct RaidSuggestion: Codable, Hashable, Identifiable {
    var id: Int { raidID }
    let raidID: Int
    let raidName: String
    let raidImageURI: String
    let items: [RaidSuggestionItem]
}

struct RaidSuggestionItem: Codable, Hashable, Identifiable {
    // I am comparing it on the name, because of cases where mount is obtainable from two bosses:
    // one is G.M.O.D which has the same id for both Jaina and High Tinker, but the other is
    // mammoth from WotLK PVP raid, which has the same name, but different IDs.
    static func == (lhs: RaidSuggestionItem, rhs: RaidSuggestionItem) -> Bool {
        return lhs.name == rhs.name
    }
    let id: Int
    let name: String
    let quality: itemQualityName
    let iconURI: String
}
