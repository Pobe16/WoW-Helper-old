//
//  UserProfile.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 14/08/2020.
//

import Foundation

struct UserProfile: Decodable, Hashable {
    let _links: LinksInProfile
    let id: Int
    let wowAccounts: [Account]
    let collections: LinkStub
}

struct LinksInProfile: Decodable, Hashable {
    let `self`: LinkStub
    let user: LinkStub
    let profile: LinkStub
}

struct Account: Decodable, Hashable {
    let id: Int
    let characters: [CharacterInProfile]
}

struct CharacterInProfile: Decodable, Hashable, Identifiable {
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
}

struct placeholders{
    static let characterInProfile = CharacterInProfile(
        character: LinkStub(href: ""),
        protectedCharacter: LinkStub(href: ""),
        name: "Pobe",
        id: 105830991,
        realm: RealmInProfile(
            key: LinkStub(href: ""),
            name: "Defias Brotherhood",
            id: 635,
            slug: "defias-brotherhood"
        ),
        playableClass: ClassInProfile(
            key: LinkStub(href: ""),
            name: "Shaman",
            id: 7
        ),
        playableRace: RaceInProfile(
            key: LinkStub(href: ""),
            name: "Dwarf",
            id: 3
        ), gender: GenderInProfile(
            type: "MALE",
            name: "Male"
        ), faction: Faction(
            type: "ALLIANCE",
            name: "Alliance"
        ),
        level: 120)
}

struct RealmInProfile: Decodable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
    let slug: String
}

struct ClassInProfile: Decodable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
}

struct RaceInProfile: Decodable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
}

struct GenderInProfile: Decodable, Hashable {
    let type: String
    let name: String
}

struct Faction: Decodable, Hashable {
    let type: String
    let name: String
}


struct LinkStub: Decodable, Hashable {
    let href: String
}
