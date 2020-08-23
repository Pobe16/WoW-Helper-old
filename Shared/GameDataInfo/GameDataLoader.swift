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
    @State var timeRetries: Int = 0
    @State var connectionRetries: Int = 0
    
    var body: some View {
        HStack{
            Image(systemName: "chart.bar.doc.horizontal")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: 63, height: 63)
                .cornerRadius(15, antialiased: true)
            Text("Data Health")
            if !gameData.loadingAllowed{
                Spacer()
                ProgressView(
                    value:  Double(gameData.downloadedItems),
                    total: Double(max(gameData.estimatedItemsToDownload, gameData.actualItemsToDownload))
                )
//                .progressViewStyle(DefaultProgressViewStyle())
//                .progressViewStyle(CircularProgressViewStyle())
            }
            
        }
        .onAppear {
//                    debug
//                    deleteAllJSONData()
                    loadExpansionIndex()
        }
    }
    
    func deleteAllJSONData() {
        let allData = JSONCoreDataManager.shared.fetchAllJSONData()
        allData?.forEach({ item in
            JSONCoreDataManager.shared.deleteJSONData(data: item)
        })
    }
    
    func loadExpansionIndex() {
        
        if self.gameData.expansions.count == 0 && self.gameData.loadingAllowed {
            withAnimation {
                self.gameData.loadingAllowed = false
            }
            let requestUrlAPIHost = UserDefaults.standard.object(forKey: "APIRegionHost") as? String ?? APIRegionHostList.Europe
            let requestUrlAPIFragment = "/data/wow/journal-expansion/index"
            
            if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlAPIHost + requestUrlAPIFragment, maximumAgeInDays: 90) {
                self.decodeExpansionIndexData(savedData.data!)
                return
            }
            
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
    }
    
    func decodeExpansionIndexData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(ExpansionTop.self, from: data)
            print(dataResponse.tiers.count)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            DispatchQueue.main.async {
                self.gameData.expansionsStubs = dataResponse.tiers
                self.gameData.actualItemsToDownload += dataResponse.tiers.count
                self.loadExpansionJournal()
                
            }
            
        } catch {
            print(error)
        }
    }
    
    func loadExpansionJournal() {
        
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            return
        }
        
        guard let stub = self.gameData.expansionsStubs.first else {
            if self.gameData.expansions.count > 0 {
                print("finished loading expansions")
                print("loaded \(self.gameData.expansions.count) expansions")
                DispatchQueue.main.async {
                    withAnimation {
                        self.gameData.expansions.sort()
                        self.gameData.actualItemsToDownload += self.gameData.raidsStubs.count
                        self.gameData.actualItemsToDownload += self.gameData.dungeonsStubs.count
                    }
                }
                
                loadRaidsInfo()
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("data saving problem - retrying in 1s")
                loadExpansionJournal()
            }
            return
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2?.accessToken ?? ""
        
        let requestUrlAPIHost = "\(stub.key.href)"
        
        let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
            self.decodeExpansionJournalData(savedData.data!)
            return
        }
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(accessToken)"
        )!
        
        
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
            if let data = data {
                timeRetries = 0
                connectionRetries = 0
                
                self.decodeExpansionJournalData(data, fromURL: fullRequestURL)
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadExpansionJournal()
                }
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
                    self.gameData.downloadedItems += 1
                }
                
                self.gameData.raidsStubs.append(contentsOf: dataResponse.raids ?? [])
                self.gameData.dungeonsStubs.append(contentsOf: dataResponse.dungeons ?? [])
//                self.gameData.encountersStubs.append(contentsOf: dataResponse.worldBosses ?? [])
                
                if self.gameData.expansionsStubs.count > 0 {
                    self.gameData.expansionsStubs.removeFirst()
                }
                
                loadExpansionJournal()
            }
            
            
        } catch {
            print(error)
        }
    }
    
    func loadRaidsInfo(){
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            return
        }
        guard let currentRaidToLoad = self.gameData.raidsStubs.first else {
            if self.gameData.raids.count > 0 {
                print("finished loading raids")
                print("loaded \(self.gameData.raids.count) raids")
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.gameData.raids.sort()
                    }
                }
                
                loadDungeonsInfo()
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadRaidsInfo()
            }
            return
        }
        
        let requestUrlAPIHost = "\(currentRaidToLoad.key.href)"
        
        let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
            self.decodeRaidData(savedData.data!)
            return
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2?.accessToken ?? ""
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(accessToken)"
        )!
        
        
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
            if let data = data {
                timeRetries = 0
                connectionRetries = 0
                
                self.decodeRaidData(data, fromURL: fullRequestURL)
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error.localizedDescription)
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadRaidsInfo()
                }
            }
        }
        task?.resume()
        
    }
    func decodeRaidData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(InstanceJournal.self, from: data)
            
//          For some reason Blizz have put a Greater Legion Invasion here as a raid…
//          I'm not allowing it.
            if dataResponse.category.type == "EVENT" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.gameData.raidsStubs.count > 0{
                        self.gameData.raidsStubs.removeFirst()
                    }
                    loadRaidsInfo()
                }
                return
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async {
                withAnimation {
                    self.gameData.raids.append(dataResponse)
                    self.gameData.downloadedItems += 1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.gameData.raidsStubs.count > 0{
                    self.gameData.raidsStubs.removeFirst()
                }
                loadRaidsInfo()
            }
            
        } catch {
            print(error)
        }
    }
    
    func loadDungeonsInfo(){
        if timeRetries > 5 || connectionRetries > 5 {
            print("Failed after \(timeRetries) timer retries, and or \(connectionRetries) connection errors")
            return
        }
        guard let currentDungeonToLoad = self.gameData.dungeonsStubs.first else {
            if self.gameData.dungeons.count > 0 {
                print("finished loading dungeons")
                // some dungeons are doubled, as they were "refreshed" in newer expansions,
                // but it does not reflect in their "expansion id", just in the expansion journal
                // here I am removing duplicates, and sorting it
                let noDuplicates = Array(Set(self.gameData.dungeons))

                DispatchQueue.main.async {
                    withAnimation {
                        self.gameData.dungeons = noDuplicates.sorted()
                        self.gameData.loadingAllowed = true
                    }
                }
                print("loaded \(self.gameData.dungeons.count) dungeons")
                return
            }
            timeRetries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadRaidsInfo()
            }
            return
        }
        
        let requestUrlAPIHost = "\(currentDungeonToLoad.key.href)"
        
        let strippedAPIUrl = String(requestUrlAPIHost.split(separator: "?")[0])
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 90) {
            self.decodeDungeonData(savedData.data!)
            return
        }
        
        let requestLocale = UserDefaults.standard.object(forKey: "localeCode") as? String ?? EuropeanLocales.BritishEnglish
        let accessToken = authorization.oauth2?.accessToken ?? ""
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(accessToken)"
        )!
        
        
        guard let req = authorization.oauth2?.request(forURL: fullRequestURL) else { return }
        
        let task = authorization.oauth2?.session.dataTask(with: req) { data, response, error in
            if let data = data {
                timeRetries = 0
                connectionRetries = 0
                
                self.decodeDungeonData(data, fromURL: fullRequestURL)
                
            }
            if let error = error {
                // something went wrong, check the error
                print("error, retrying in 1 second")
                print(error.localizedDescription)
                connectionRetries += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadRaidsInfo()
                }
            }
        }
        task?.resume()
        
    }
    func decodeDungeonData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let dataResponse = try decoder.decode(InstanceJournal.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
                
            DispatchQueue.main.async {
                
                withAnimation {
                    self.gameData.dungeons.append(dataResponse)
                    self.gameData.downloadedItems += 1
                }
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.gameData.dungeonsStubs.count > 0 {
                    self.gameData.dungeonsStubs.removeFirst()
                }
                loadDungeonsInfo()
            }
            
        } catch {
            print(error)
        }
    }
    
}

