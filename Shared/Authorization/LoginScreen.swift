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
        GeometryReader { geo in
            VStack {
                
                Spacer()
                HStack {
                    Spacer(minLength: 0)
                    VStack {
                        Text("Region:")
                            .font(.title2)
                        
                        Picker(selection: $region, label: Text("Region"), content: {
                            Text("Americas").tag(0)
                                .minimumScaleFactor(0.5)
                            Text("Europe").tag(1)
                            Text("Korea").tag(2)
                            Text("Taiwan").tag(3)
                            Text("China").tag(4)
                        })
                        .pickerStyle(DefaultPickerStyle())
                        .frame(width: geo.size.width > 325 ? 340 : 270, height: 90)
                        .clipped()
                        .onChange(of: region, perform: { value in
                            locale = 0
                        })
                        
                        Text("Language:")
                            .font(.title2)
                        
                        Picker(selection: $locale, label: Text("Language"), content: {
                            if region == 0 {
                                Text("🇺🇸 US English").tag(0)
                                Text("🇲🇽 Mexican Spanish").tag(1)
                                Text("🇧🇷 Brazilian Portuguese").tag(2)
                            } else if region == 1 {
                                Text("🏴󠁧󠁢󠁳󠁣󠁴󠁿 \(locale == 0 ? "Better " : "")English").tag(0)
                                Text("🇬🇧 British English").tag(-1)
                                Text("🇪🇸 Spanish").tag(1)
                                Text("🇫🇷 French").tag(2)
                                Text("🇷🇺 Russian").tag(3)
                                Text("🇩🇪 Deutsch").tag(4)
                                Text("🇵🇹 Portuguese").tag(5)
                                Text("🇮🇹 Italian").tag(6)
                            } else if region == 2 {
                                Text("🇰🇷 Korean").tag(0)
                            } else if region == 3 {
                                Text("🇹🇼 Taiwanese").tag(0)
                            } else if region == 4 {
                                Text("🇨🇳 Chinese").tag(0)
                            }
                        })
                        .pickerStyle(DefaultPickerStyle())
                        .frame(width: geo.size.width > 325 ? 340 : 270, height: 90)
                        .clipped()
                        
                    }
                    .padding()
                    .background(
                        BackgroundTexture(texture: .ice, wall: .all)
                    )
                    .cornerRadius(15)
                    
                    Spacer(minLength: 0)
                }
            
            
                Spacer()
                    .frame(height: 30)
                
                Button(action: {
                    authenticate()
                }, label: {
                    Text("Authorize me!")
                        .font(.title)
                        .whiteTextWithBlackOutlineStyle()
                })
                .padding()
                .frame(width: geo.size.width > 325 ? 340 : 270)
                .background(
                    BackgroundTexture(texture: .wood, wall: .all)
                )
                .cornerRadius(15)
                
                
                Spacer()
                    
            }
            .onAppear(perform: {
                determineLocaleState()
            })
        }
        .background(
            BackgroundTexture(texture: .flagstone, wall: .none)
        )
    }
    
    func determineLocaleState() {
        region = UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)
        locale = UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginLocale)
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
        UserDefaults.standard.setValue(authHost, forKey: UserDefaultsKeys.authHost)
        UserDefaults.standard.setValue(APIRegionHost, forKey: UserDefaultsKeys.APIRegionHost)
        UserDefaults.standard.setValue(localeCode, forKey: UserDefaultsKeys.localeCode)
        
        UserDefaults.standard.setValue(region, forKey: UserDefaultsKeys.loginRegion)
        UserDefaults.standard.setValue(locale, forKey: UserDefaultsKeys.loginLocale)
        
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
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.UserLoggedBefore)
            } else {
                authorization.loggedIn = false
                print("Authorization was canceled or went wrong: \(String(describing: error))")   // error will not be nil
            }
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
            .environmentObject(Authentication.init())
    }
}
