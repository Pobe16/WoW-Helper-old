//
//  ExpansionIndex.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import Foundation

struct ExpansionTop: Codable, Hashable {
    let tiers: [ExpansionIndex]
//    let _links: JustSelfLink
}

struct ExpansionIndex: Codable, Hashable, Identifiable {
    let id: Int
    let key: LinkStub
    let name: String
}
