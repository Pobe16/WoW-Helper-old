//
//  JournalEncounterSearch.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 27/09/2020.
//

import Foundation

struct JournalEncounterSearch: Codable, Hashable {
    let maxPageSize: Int
    let page: Int
    let pageCount: Int
    let pageSize: Int
    let results: [JournalEncounterSearchWrapper]
}

struct JournalEncounterSearchWrapper: Codable, Hashable {
    let data: JournalEncounter
    let key: LinkStub
}

struct JournalEncounter: Codable, Hashable, Comparable {
    static func == (lhs: JournalEncounter, rhs: JournalEncounter) -> Bool {
        return lhs.id == rhs.id && lhs.instance.id == rhs.instance.id
    }
    
    static func < (lhs: JournalEncounter, rhs: JournalEncounter) -> Bool {
        if lhs.instance.id == rhs.instance.id {
            return lhs.id < rhs.id
        } else {
            return lhs.instance.id < rhs.instance.id
        }
    }
    
    let category: EncounterCategory
    let id: Int
    let instance: EncounterInstance
    let items: [ItemWrapper]
    let name: LocalizedName
}

struct EncounterCategory: Codable, Hashable {
    let type: String
}

struct EncounterInstance: Codable, Hashable {
    let id: Int
    let name: LocalizedName
}

struct ItemWrapper: Codable, Hashable {
    let id: Int
    let item: ItemStub
}

struct ItemStub: Codable, Hashable {
    static func == (lhs: ItemStub, rhs: ItemStub) -> Bool {
        lhs.id == rhs.id
    }
    
    let name: LocalizedName
    let id: Int
}


