//
//  UserProfile.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 14/08/2020.
//

import Foundation

struct UserProfile: Codable, Hashable {
    let _links: LinksInProfile
    let id: Int
    let wowAccounts: [Account]?
    let collections: LinkStub
}

struct LinksInProfile: Codable, Hashable {
    let `self`: LinkStub
    let user: LinkStub
    let profile: LinkStub
}

struct Account: Codable, Hashable {
    let id: Int
    let characters: [CharacterInProfile]
}

struct CharacterInProfile: Codable, Hashable, Identifiable {
    let character: LinkStub
    let protectedCharacter: LinkStub
    let name: String
    let id: Int
    let realm: RealmInProfile
    let playableClass: ClassInProfile
    let playableRace: RaceInProfile
    let gender: GenderInProfile
    let faction: Faction
    let level: Int
    var avatar: Data?
}

struct RealmInProfile: Codable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
    let slug: String
}

struct ClassInProfile: Codable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
}

struct RaceInProfile: Codable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
}

struct GenderInProfile: Codable, Hashable {
    let type: GenderType
    let name: String
}

enum GenderType: String, Codable, Hashable {
    case male       = "MALE"
    case female     = "FEMALE"
}

struct Faction: Codable, Hashable {
    let type: FactionType
    let name: String
}

enum FactionType: String, Codable {
    case alliance   = "ALLIANCE"
    case horde      = "HORDE"
    case neutral    = "NEUTRAL"
}


struct LinkStub: Codable, Hashable {
    let href: String
}
