//
//  CharacterMedia.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 14/08/2020.
//

import Foundation

class CharacterMedia: Decodable {
//    let _links: LinksInCharacterMedia
//    let character: CharacterInfoInCharacterMedia
    let avatarUrl: String
    let bustUrl: String?
    let renderUrl: String?
    
}

//struct LinksInCharacterMedia: Decodable {
//    let `self`: LinkStub
//}
//
//struct CharacterInfoInCharacterMedia: Decodable {
//    let key: LinkStub
//    let name: String
//    let id: Int
//    let realm: RealmInProfile
//}
