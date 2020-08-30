//
//  CharacterRaidEncounters.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 30/08/2020.
//

import Foundation

struct CharacterRaidEncounters: Decodable, Hashable {
    let _links: JustSelfLink?
    let character: CharacterStubInEncounters
    let expansions: [EncounterInExpansion]?
}

struct CharacterStubInEncounters: Decodable, Hashable {
    let key: LinkStub
    let name: String
    let id: Int
    let realm: RealmInProfile
}

struct EncounterInExpansion: Decodable, Hashable {
    let expansion: ExpansionIndex
    let instances: [RaidInstancesInCharacterEncounters]
}

struct RaidInstancesInCharacterEncounters: Decodable, Hashable {
    let instance: InstanceIndex
    let modes: [RaidEncountersForCharacter]
}

struct RaidEncountersForCharacter: Decodable, Hashable {
    let difficulty: InstanceModesNames
    let status: InstanceStatus
    let progress: InstanceProgress
}

struct InstanceStatus: Decodable, Hashable {
    let type: String
    let name: String
}

struct InstanceProgress: Decodable, Hashable {
    let completedCount: Int
    let totalCount: Int
    let encounters: [EncounterPerBossPerCharacter]
}

struct EncounterPerBossPerCharacter: Decodable, Hashable {
    let completedCount: Int
    let encounter: EncounterIndex
    let lastKillTimestamp: Date
    
}

