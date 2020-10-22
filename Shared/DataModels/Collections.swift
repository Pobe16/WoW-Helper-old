//
//  Collections.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 20/10/2020.
//

import Foundation

struct MountsCollection: Hashable, Codable {
    let mounts: [MountWrapper]?
}

struct MountWrapper: Hashable, Codable {
    let mount: MountStub
}

struct MountStub: Hashable, Codable {
    let key: LinkStub
    let name: String
    let id: Int
}

struct PetsCollection: Hashable, Codable {
    let pets: [PetWrapper]?
}

struct PetWrapper: Hashable, Codable {
    let species: PetSpecies
}

struct PetSpecies: Hashable, Codable {
    let key: LinkStub
    let name: String
    let id: Int
}
