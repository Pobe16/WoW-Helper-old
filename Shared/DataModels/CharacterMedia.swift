//
//  CharacterMedia.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 14/08/2020.
//

import Foundation

class CharacterMedia: Codable {
    let avatarUrl: String?
    let bustUrl: String?
    let renderUrl: String?
    let assets: [MediaAssets]?
}

struct JustSelfLink: Codable, Hashable {
    let `self`: LinkStub
}
