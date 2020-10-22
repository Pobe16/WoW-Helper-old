//
//  AuthInfo.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 09/08/2020.
//

import Foundation

struct BattleNetAuthorizationHostList {
    static let NorthAmerica             = "https://us.battle.net/oauth"
    static let Europe                   = "https://eu.battle.net/oauth"
    static let Korea                    = "https://apac.battle.net/oauth"
    static let Taiwan                   = "https://apac.battle.net/oauth"
    static let China                    = "https://www.battlenet.com.cn/oauth"
}

struct APIRegionHostList {
    static let NorthAmerica             = "https://us.api.blizzard.com"
    static let Europe                   = "https://eu.api.blizzard.com"
    static let Korea                    = "https://kr.api.blizzard.com"
    static let Taiwan                   = "https://tw.api.blizzard.com"
    static let China                    = "https://gateway.battlenet.com.cn"
}

struct APIRegionShort {
    static let Code                     = ["us", "eu", "kr", "tw", "cn"]
}

struct AmericanLocales {
    static let USEnglish                = "en_US"
    static let MexicanSpanish           = "es_MX"
    static let BrazilianPortuguese      = "pt_BR"
}

struct EuropeanLocales {
    static let BritishEnglish           = "en_GB"
    static let Spanish                  = "es_ES"
    static let French                   = "fr_FR"
    static let Russian                  = "ru_RU"
    static let German                   = "de_DE"
    static let Portuguese               = "pt_PT"
    static let Italian                  = "it_IT"
}

struct KoreanLocales {
    static let Korean                   = "ko_KR"
}

struct TaiwaneseLocales {
    static let Taiwanese                = "zh_TW"
}

struct ChineseLocales {
    static let Chinese                  = "zh_CN"
}
