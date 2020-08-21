//
//  GameDataLoader.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 21/08/2020.
//

import SwiftUI

struct GameDataLoader: View {
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        HStack{
            Image(systemName: "chart.bar.doc.horizontal")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: 63, height: 63)
                .cornerRadius(15, antialiased: true)
            Text("Data Health")
        }
        .onAppear {
            loadExpansionIndex()
        }
    }
    
    func loadExpansionIndex() {
        if self.gameData.expansionsStubs.count == 0 {
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
            
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlAPIHost + requestUrlAPIFragment, maximumAgeInDays: 90) {
                
                self.decodeExpansionIndexData(savedData.data!)
                return
            }
            
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
    }
    
    func decodeExpansionIndexData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionTop.self, from: data)
            print(dataResponse.tiers.count)
            self.gameData.expansionsStubs = dataResponse.tiers
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            
            self.gameData.expansionsStubs.forEach { expansion in
                loadExpansionJournal(for: expansion)
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
        
        let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
            self.decodeExpansionJournalData(savedData.data!)
            return
        }
        
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

