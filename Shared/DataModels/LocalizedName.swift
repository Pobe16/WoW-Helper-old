//
//  LocalizedName.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 27/09/2020.
//

import Foundation

// swiftlint:disable identifier_name
struct LocalizedName: Codable, Hashable {
    let en_US: String
    let es_MX: String
    let pt_BR: String
    let de_DE: String
    let en_GB: String
    let es_ES: String
    let fr_FR: String
    let it_IT: String
    let ru_RU: String
    let ko_KR: String
    let zh_TW: String
    let zh_CN: String
    var value: String {
        let requestLocale = UserDefaults.standard.object(
            forKey: UserDefaultsKeys.localeCode
        ) as? String ?? EuropeanLocales.BritishEnglish
        switch requestLocale {
        case "en_US":
            return en_US
        case "es_MX":
            return es_MX
        case "pt_BR":
            return pt_BR
        case "de_DE":
            return de_DE
        case "en_GB":
            return en_GB
        case "es_ES":
            return es_ES
        case "fr_FR":
            return fr_FR
        case "it_IT":
            return it_IT
        case "ru_RU":
            return ru_RU
        case "ko_KR":
            return ko_KR
        case "zh_TW":
            return zh_TW
        case "zh_CN":
            return zh_CN
        default:
            return en_GB
        }
    }
}
// swiftlint:enable identifier_name
