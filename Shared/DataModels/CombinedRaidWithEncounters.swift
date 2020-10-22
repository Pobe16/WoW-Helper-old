//
//  CombinedRaidWithEncounters.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 31/08/2020.
//

import Foundation

struct CombinedRaidWithEncounters: Hashable, Identifiable {
    var id: Int {
        return raidId
    }
    var background: Data?
    let raidId: Int
    let raidName: String
    let description: String?
    let minimumLevel: Int
    let expansion: ExpansionIndex
    let media: InstanceMediaStub
    let modes: [InstanceMode]
    let records: [RaidEncountersForCharacter]
}
