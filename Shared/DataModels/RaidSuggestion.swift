//
//  RaidSuggestion.swift
//  WoW Helper
//
//  Created by Mikolaj Lukasik on 15/11/2020.
//

import Foundation

struct RaidsSuggestedForCharacter: Codable, Hashable, Identifiable {
    var id = UUID()
    let characterID: Int
    let characterName: String
    let characterLevel: Int
    let characterRealmSlug: String
    let characterAvatarURI: String
    let characterFaction: FactionType
    let raids: [RaidSuggestion]
}

struct RaidSuggestion: Codable, Hashable, Identifiable {
    var id = UUID()
    let raidID: Int
    let raidName: String
    let raidImageURI: String
    let items: [RaidSuggestionItem]
}

struct RaidSuggestionItem: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let quality: itemQualityName
    let iconURI: String
}
