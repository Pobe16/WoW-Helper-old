//
//  JournalEncounterSearch.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 27/09/2020.
//

import Foundation

struct JournalEncounterSearch: Codable {
    let maxPageSize: Int
    let page: Int
    let pageCount: Int
    let pageSize: Int
    let results: [JournalEncounterSearchWrapper]
}

struct JournalEncounterSearchWrapper: Codable {
    let data: JournalEncounter
    let key: LinkStub
}

struct JournalEncounter: Codable {
    let category: EncounterCategory
    let id: Int
    let instance: EncounterInstance
    let items: [ItemWrapper]
    let name: LocalizedName
}

struct EncounterCategory: Codable {
    let type: String
}

struct EncounterInstance: Codable {
    let id: Int
    let name: LocalizedName
}

struct ItemWrapper: Codable {
    let id: Int
    let item: ItemStub
}

struct ItemStub: Codable {
    let name: LocalizedName
    let id: Int
}
