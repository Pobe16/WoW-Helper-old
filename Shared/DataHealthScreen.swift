//
//  DataHealthScreen.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import SwiftUI

struct DataHealthScreen: View {
    @EnvironmentObject var authorization: Authentication
    @State var expansionsStubs: [ExpansionIndex] = []
    @State var expansionInfo: [String:ExpansionJournal] = [:]
    
    var body: some View {
        VStack {
            Text("Expansion:")
                .onAppear(perform: {
                    self.loadExpansionIndex()
                })
            VStack{
                if expansionsStubs.count > 0 {
                    ForEach(expansionsStubs){ expansion in
                        HStack{
                            Text(expansion.name)
                            if expansionInfo[expansion.name] != nil {
                                if expansionInfo[expansion.name]?.dungeons != nil {
                                    Text("Dungeons: \(expansionInfo[expansion.name]?.dungeons!.count ?? 0)")
//                                    ForEach(expansionInfo[expansion.name].dungeons) { dungeon in
//                                        Text("\(dungeon.name)")
//                                    }
                                }
                                if expansionInfo[expansion.name]?.raids != nil {
                                    Text("Raids: \(expansionInfo[expansion.name]?.raids!.count ?? 0)")
//                                    ForEach(expansionInfo[expansion.name].raids) { raid in
//                                        Text("\(raid.name)")
//                                    }
                                }
                                if expansionInfo[expansion.name]?.worldBosses != nil {
                                    Text("World Bosses: \(expansionInfo[expansion.name]?.worldBosses!.count ?? 0)")
//                                    ForEach(expansionInfo[expansion.name].worldBosses) { worldBoss in
//                                        Text("\(worldBoss.name)")
//                                    }
                                }
                            }
                            
                        }
                        
                    }
                } else {
                    EmptyView()
                }
            }
            
        }
        
    }
    
    func loadExpansionIndex() {
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: "APIRegionHost") as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/journal-expansion/index"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: "loginRegion")]
        let requestAPINamespace = "static-\(regionShortCode)"
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
                    let dataResponse = try decoder.decode(ExpansionTop.self, from: data)
                    self.expansionsStubs = dataResponse.tiers
                    
//                    for expansion in dataResponse.tiers {
                        
//                        withAnimation {
//                            self.characters.append(contentsOf: account.characters)
//                        }
                        
//                    }
                    self.expansionsStubs.forEach { expansion in
                        loadExpansionJournal(for: expansion)
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
    func loadExpansionJournal(for expansion: ExpansionIndex) {
        let requestUrlAPIHost = "\(expansion.key.href)"
        
        let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
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
                    let dataResponse = try decoder.decode(ExpansionJournal.self, from: data)
                    
                    withAnimation {
                        self.expansionInfo[expansion.name] = dataResponse
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
