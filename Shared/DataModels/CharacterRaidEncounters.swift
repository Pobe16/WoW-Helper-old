//
//  CharacterRaidEncounters.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 30/08/2020.
//

import Foundation

struct CharacterRaidEncounters: Codable, Hashable {
    let _links: JustSelfLink?
    let character: CharacterStubInEncounters
    let expansions: [EncounterInExpansion]?
}

struct CharacterStubInEncounters: Codable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
    let realm: RealmInProfile
}

struct EncounterInExpansion: Codable, Hashable {
    let expansion: ExpansionIndex
    let instances: [RaidInstancesInCharacterEncounters]
}

struct RaidInstancesInCharacterEncounters: Codable, Hashable {
    let instance: InstanceIndex
    let modes: [RaidEncountersForCharacter]
}

struct RaidEncountersForCharacter: Codable, Hashable {
    let difficulty: InstanceModeName
    let status: InstanceStatus
    let progress: InstanceProgress
}

struct InstanceStatus: Codable, Hashable {
    let type: String
    let name: String
}

struct InstanceProgress: Codable, Hashable {
    let completedCount: Int
    let totalCount: Int
    let encounters: [EncounterPerBossPerCharacter]
}

struct EncounterPerBossPerCharacter: Codable, Hashable {
    let completedCount: Int
    let encounter: EncounterIndex
    let lastKillTimestamp: Date?
    
}

