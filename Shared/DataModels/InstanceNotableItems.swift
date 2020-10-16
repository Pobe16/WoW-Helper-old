//
//  InstanceNotableItems.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 16/10/2020.
//

import Foundation

enum itemQualityName: String {
    case poor       = "poor"
    case common     = "common"
    case uncommon   = "uncommon"
    case rare       = "rare"
    case epic       = "epic"
    case legendary  = "legendary"
    case heirloom   = "heirloom"
    case artifact   = "artifact"
}

struct InstanceNotableItems: Hashable, Equatable {
    
    let id: Int
    let mounts: [QualityItemStub]
    let pets: [QualityItemStub]
}

struct QualityItemStub: Hashable{
    static func == (lhs: QualityItemStub, rhs: QualityItemStub) -> Bool {
        lhs.id == lhs.id
    }
    
    let name: LocalizedName
    let id: Int
    let quality: itemQualityName
}
