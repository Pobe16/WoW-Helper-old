//
//  DataHealthScreen.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import SwiftUI

struct DataHealthScreen: View {
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    @State var gameDataCreationDate: String = ""
//    @State var expansionInfo: [String:ExpansionJournal] = [:]
    
    var body: some View {
        VStack {
            Text("Expansions:")
                
            VStack{
                if gameData.expansions.count > 0 {
                    ForEach(gameData.expansions){ expansion in
                        HStack{
                            Text(expansion.name)
                            if expansion.dungeons != nil {
                                Text("Dungeons: \(expansion.dungeons?.count ?? 0)")
                            }
                            if expansion.raids != nil {
                                Text("Raids: \(expansion.raids?.count ?? 0)")
                            }
                            if expansion.worldBosses != nil {
                                Text("World Bosses: \(expansion.worldBosses?.count ?? 0)")
                            }

                        }

                    }
                } else {
                    EmptyView()
                }
                
                Spacer()
                
                Text("Last refreshed:")
                Text(gameDataCreationDate)
                Button {
                    self.loadExpansionIndex()
                } label: {
                    Text("Refresh now!")
                }

            }
            
        }
        .onAppear(perform: {
            self.checkDataCreationDate()
        })
        
    }
    
    func checkDataCreationDate(){
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: "APIRegionHost") as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/journal-expansion/index"
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlAPIHost + requestUrlAPIFragment, maximumAgeInDays: 90) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = dateFormatter.string(from: savedData.creationDate!)
            self.gameDataCreationDate = dateString
        } else {
            self.gameDataCreationDate = "Nothing saved"
        }
    }
    
    func deleteDataBeforeUpdating() {
        DispatchQueue.main.async {
            withAnimation {
                self.gameData.expansions    = []
                self.gameData.raids         = []
                self.gameData.dungeons      = []
                self.gameData.encounters    = []
            }
            
        }
    }
    
    func loadExpansionIndex() {
        deleteDataBeforeUpdating()
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
        
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.decodeExpansionIndexData(data, fromURL: fullRequestURL)
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task?.resume()
    }
    
    func decodeExpansionIndexData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionTop.self, from: data)
            DispatchQueue.main.async {
                withAnimation {
                    self.gameData.expansionsStubs = dataResponse.tiers
                }
                self.gameData.expansionsStubs.forEach { expansion in
                    loadExpansionJournal(for: expansion)
                }
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
                self.checkDataCreationDate()
            }
        } catch {
            print(error)
        }
    }
    
    func loadExpansionJournal(for expansion: ExpansionIndex) {
        let requestUrlAPIHost = "\(expansion.key.href)"
        
        let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2?.accessToken ?? "")"
        )!
        
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
            if let data = data {
                
                self.decodeExpansionJournalData(data, fromURL: fullRequestURL)
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task?.resume()
    }
    
    func decodeExpansionJournalData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionJournal.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async {
                withAnimation {
                    self.gameData.expansions.append(dataResponse)
                    self.gameData.expansions.sort()
                }
            }
            
        } catch {
            print(error)
        }
    }
}
