//
//  PlaceHolders.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 16/10/2020.
//

import Foundation

struct placeholders{
    static let characterInProfile = CharacterInProfile(
        character: LinkStub(href: ""),
        protectedCharacter: LinkStub(href: ""),
        name: "Pobe",
        id: 105830991,
        realm: RealmInProfile(
            key: LinkStub(href: ""),
            name: "Defias Brotherhood",
            id: 635,
            slug: "defias-brotherhood"
        ),
        playableClass: ClassInProfile(
            key: LinkStub(href: ""),
            name: "Shaman",
            id: 7
        ),
        playableRace: RaceInProfile(
            key: LinkStub(href: ""),
            name: "Dwarf",
            id: 3
        ), gender: GenderInProfile(
            type: .male,
            name: "Male"
        ), faction: Faction(
            type: .alliance,
            name: "Alliance"
        ),
        level: 120)
    static let itemStub = ItemStub(name: LocalizedName(en_US: "Invincible's Reins", es_MX: "Riendas de Invencible", pt_BR: "Rédeas do Invencível", de_DE: "Unbesiegbars Zügel", en_GB: "Invincible's Reins", es_ES: "Riendas de Invencible", fr_FR: "Rênes d'Invincible", it_IT: "Redini di Invincibile", ru_RU: "Поводья Непобедимого", ko_KR: "천하무적의 고삐", zh_TW: "無敵的韁繩", zh_CN: "无敌的缰绳"), id: 50818)
    static let qualityItemStub = QualityItemStub(name: LocalizedName(en_US: "Invincible's Reins", es_MX: "Riendas de Invencible", pt_BR: "Rédeas do Invencível", de_DE: "Unbesiegbars Zügel", en_GB: "Invincible's Reins", es_ES: "Riendas de Invencible", fr_FR: "Rênes d'Invincible", it_IT: "Redini di Invincibile", ru_RU: "Поводья Непобедимого", ko_KR: "천하무적의 고삐", zh_TW: "無敵的韁繩", zh_CN: "无敌的缰绳"), id: 50818, quality: .epic)
}
