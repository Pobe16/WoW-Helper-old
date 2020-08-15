//
//  MainScreen.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 13/08/2020.
//

import SwiftUI

struct MainScreen: View {
    @Binding var loggedIn: Bool
    @EnvironmentObject var authorization: Authentication
    @State var characters: [CharacterInProfile] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(characters) { character in
                    CharacterListItem(character: character)
                }
                
                Button(action: {
                    self.logOut()
                }, label: {
                    Text("Log me out!")
                })
            }.navigationBarTitle("WoWWidget", displayMode: .large)
        }.onAppear {
            self.loadCharacters()
        }
        
    }
    
    fileprivate func logOut() {
        
        print(authorization.oauth2?.accessToken as Any)
        authorization.oauth2?.forgetTokens()
        loggedIn = false
    }
    
    func loadCharacters() {
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: "APIRegionHost") as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/profile/user/wow"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: "loginRegion")]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2?.accessToken ?? "")"
        )!
        print(fullRequestURL)
        
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
            if let data = data {
                print(data)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let dataResponse = try decoder.decode(UserProfile.self, from: data)
                    
                    for account in dataResponse.wowAccounts {
                        for userCharacter in account.characters {
                            DispatchQueue.main.async {
                                self.characters.append(userCharacter)
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
                
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task?.resume()
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(loggedIn: .constant(true))
    }
}