//
//  LoginScreen.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 12/08/2020.
//

import OAuth2
import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var authorization: Authentication
    @State private var region = 1
    @State private var locale = 0
    
    var body: some View {
        VStack{
            Spacer()
            Picker(selection: $region, label: Text("Region"), content: /*@START_MENU_TOKEN@*/{
                Text("America").tag(0)
                Text("Europe").tag(1)
                Text("Korea").tag(2)
                Text("Taiwan").tag(3)
                Text("China").tag(4)
            }/*@END_MENU_TOKEN@*/)
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: region, perform: { value in
                locale = 0
            })
            if region == 0 {
                Picker(selection: $locale, label: Text("Language"), content: /*@START_MENU_TOKEN@*/{
                    Text("US English").tag(0)
                    Text("Mexican Spanish").tag(1)
                    Text("Brazilian Portuguese").tag(2)
                }/*@END_MENU_TOKEN@*/)
                .pickerStyle(SegmentedPickerStyle())
            } else if region == 1 {
                Picker(selection: $locale, label: Text("Language"), content: {
                    Text("🏴󠁧󠁢󠁳󠁣󠁴󠁿EN").tag(0).font(.largeTitle)
                    Text("🇬🇧EN").tag(-1)
                    Text("🇪🇸ES").tag(1)
                    Text("🇫🇷FR").tag(2)
                    Text("🇷🇺RU").tag(3)
                    Text("🇩🇪DE").tag(4)
                    Text("🇵🇹PT").tag(5)
                    Text("🇮🇹IT").tag(6)
                })
                .pickerStyle(SegmentedPickerStyle())
            } else if region == 2 {
                Picker(selection: $locale, label: Text("Language"), content: {
                        Text("Korean").tag(0)
                })
                .pickerStyle(SegmentedPickerStyle())
            } else if region == 3 {
                Picker(selection: $locale, label: Text("Language"), content: {
                        Text("Taiwanese").tag(0)
                })
                .pickerStyle(SegmentedPickerStyle())
            } else if region == 4 {
                Picker(selection: $locale, label: Text("Language"), content: {
                        Text("Chinese").tag(0)
                })
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Spacer()
                .frame(height: 30)
            
            Button(action: {
                authenticate()
            }, label: {
                Text("Authorize me")
            })
            
            Spacer()
                
        }
        .onAppear(perform: {
            determineLocaleState()
        })
        
    }
    
    func determineLocaleState() {
        region = UserDefaults.standard.integer(forKey: "loginRegion")
        locale = UserDefaults.standard.integer(forKey: "loginLocale")
    }
    
    func setLocaleForAuthorization() {
        var authHost: String
        var APIRegionHost: String
        var localeCode: String
        
//        print("Region: \(region), locale: \(locale)")
        
        switch region {
        case 0:
            authHost = BattleNetAuthorizationHostList.NorthAmerica
            APIRegionHost = APIRegionHostList.NorthAmerica
            switch locale {
            case 0:
                localeCode = AmericanLocales.USEnglish
            case 1:
                localeCode = AmericanLocales.MexicanSpanish
            case 2:
                localeCode = AmericanLocales.BrazilianPortuguese
            default:
                localeCode = AmericanLocales.USEnglish
            }
        case 1:
            authHost = BattleNetAuthorizationHostList.Europe
            APIRegionHost = APIRegionHostList.Europe
            switch locale {
            case 0, -1:
                localeCode = EuropeanLocales.BritishEnglish
            case 1:
                localeCode = EuropeanLocales.Spanish
            case 2:
                localeCode = EuropeanLocales.French
            case 3:
                localeCode = EuropeanLocales.Russian
            case 4:
                localeCode = EuropeanLocales.German
            case 5:
                localeCode = EuropeanLocales.Portuguese
            case 6:
                localeCode = EuropeanLocales.Italian
            default:
                localeCode = EuropeanLocales.BritishEnglish
            }
        case 2:
            authHost = BattleNetAuthorizationHostList.Korea
            APIRegionHost = APIRegionHostList.Korea
            localeCode = KoreanLocales.Korean
        case 3:
            authHost = BattleNetAuthorizationHostList.Taiwan
            APIRegionHost = APIRegionHostList.Taiwan
            localeCode = TaiwaneseLocales.Taiwanese
        case 4:
            authHost = BattleNetAuthorizationHostList.China
            APIRegionHost = APIRegionHostList.China
            localeCode = ChineseLocales.Chinese
        default:
            authHost = BattleNetAuthorizationHostList.Europe
            APIRegionHost = APIRegionHostList.Europe
            localeCode = EuropeanLocales.BritishEnglish
        }
        UserDefaults.standard.setValue(authHost, forKey: "authHost")
        UserDefaults.standard.setValue(APIRegionHost, forKey: "APIRegionHost")
        UserDefaults.standard.setValue(localeCode, forKey: "localeCode")
        
        UserDefaults.standard.setValue(region, forKey: "loginRegion")
        UserDefaults.standard.setValue(locale, forKey: "loginLocale")
        
    }
    
    func authenticate() {
        if let accessToken = authorization.oauth2.accessToken {
            print(accessToken)
        }
//        authorization.oauth2?.logger = OAuth2DebugLogger(.trace)
        setLocaleForAuthorization()
        
        authorization.refreshSettings()
        
        
        
        #if os(iOS)
        authorization.oauth2.authConfig.authorizeEmbedded = true
        authorization.oauth2.authConfig.authorizeContext = UIApplication.shared.windows[0].rootViewController
//        #elseif os(macOS)
//        authorization.oauth2.authConfig.authorizeContext = NSWindow
        #endif
        
//        print(authorization.settings)
        
        authorization.oauth2.authorize() { authParameters, error in
            if authParameters != nil {
//                print("Authorized! Access token is in `oauth2.accessToken`")
                authorization.loggedIn = true
                authorization.loggedBefore = true
                UserDefaults.standard.set(true, forKey: "UserLoggedBefore")
            } else {
                authorization.loggedIn = false
                print("Authorization was canceled or went wrong: \(String(describing: error))")   // error will not be nil
            }
        }
    }
}
