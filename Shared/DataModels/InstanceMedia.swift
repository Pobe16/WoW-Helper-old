//
//  InstanceMedia.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 23/08/2020.
//

import Foundation


struct InstanceMedia: Decodable, Hashable {
    let _links: JustSelfLink?
    let assets: [MediaAssets]
}

struct MediaAssets: Decodable, Hashable {
    let key: String
    let value: String
}


