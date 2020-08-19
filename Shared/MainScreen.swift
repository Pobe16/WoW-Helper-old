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
    @State var selection: String? = ""
    
    var body: some View {
        NavigationView {
            List() {
                
                Section(header: Text("Characters")){
                    if characters.count > 0 {
                        ForEach(characters) { character in
                            NavigationLink(destination: Text("\(character.name) \(character.realm.name)"), tag: "\(character.name)-\(character.realm.slug)", selection: self.$selection) {
                                CharacterListItem(character: character)
                            }
                        }
                    } else {
                        CharacterLoadingListItem()
                    }
                }
                Section(header: Text("Settings")){
                    NavigationLink(destination: DataHealthScreen(), tag: "data-health", selection: $selection) {
                        HStack{
                            Image(systemName: "chart.bar.doc.horizontal")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 63, height: 63)
                                .cornerRadius(15, antialiased: true)
                            Text("Data Health")
                            
                        }
                    }
                    
                    NavigationLink(destination: LogOutDebugScreen(loggedIn: $loggedIn), tag: "log-out", selection: $selection) {
                        LogOutListItem(loggedIn: $loggedIn)
                    }
                    
                }
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("WoWWidget", displayMode: .large)
            
            Text("Hello World!")
        }.onAppear {
            self.loadCharacters()
        }
        
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
//        print(fullRequestURL)
        
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
            if let data = data {
//                print(data)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let dataResponse = try decoder.decode(UserProfile.self, from: data)
                    
                    for account in dataResponse.wowAccounts {
                        withAnimation {
                            self.characters.append(contentsOf: account.characters)
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
            .previewLayout(.fixed(width: 2732, height: 2048))
    }
}




