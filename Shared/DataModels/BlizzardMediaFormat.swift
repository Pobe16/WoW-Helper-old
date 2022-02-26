//
//  BlizzardMediaFormat.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 23/08/2020.
//

import Foundation

struct BlizzardMediaFormat: Codable, Hashable {
// swiftlint:disable:next identifier_name
    let _links: JustSelfLink?
    let assets: [MediaAssets]
}

struct MediaAssets: Codable, Hashable {
    let key: String
    let value: String
}
