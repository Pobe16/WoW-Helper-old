//
//  RaidDetails.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 20/09/2020.
//

import SwiftUI

struct RaidDetails: View {
    @Namespace var tile
    
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    
    let columns = [
        GridItem(.adaptive(minimum: 340), spacing: 20)
    ]
    
    let raid: CombinedRaidWithEncounters
    let character: CharacterInProfile
    
    var body: some View {
        GeometryReader { geometry in
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    Section {
                        RaidTileBackground(raid: raid)
                            .frame(minWidth: 0, maxWidth: 500)
                        
                        if raid.description != nil && geometry.size.width > 600 {
                            Text(raid.description!)
                                .padding()
                        } else {
                            VStack {
                                Spacer()
                                Text("Minimum level: \(raid.minimumLevel)")
                                Spacer()
                                Text("Part of raids in \(raid.expansion.name)")
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    
                    
                    
                    ForEach(selectHighestMode(modes: raid.records), id: \.self){ raidMode in
                        Section(header: Text(raidMode.difficulty.name)) {
                            
                            ForEach(raidMode.progress.encounters, id: \.self) { encounter in
                                VStack{
                                    Text("\(encounter.encounter.name)")
                                    if encounter.lastKillTimestamp != nil {
                                        Text("Times killed: \(encounter.completedCount)")
                                            .padding()
                                        Text("Last killed: \(encounter.lastKillTimestamp!)")
                                            .padding()
                                    }
                                    
                                    if encounterDownloaded(for: encounter.encounter.id) {
                                        NotableItemsInRaid(encounter: selectEncounter(with: encounter.encounter.id))
                                    }
                                }
                                .padding()
                            }
                        }
                        
                    }
                    Section{
                        if raid.description != nil && geometry.size.width < 600 {
                            Text(raid.description!)
                        }  else {
                            VStack {
                                Text("Minimum level: \(raid.minimumLevel)")
                                Spacer()
                                Text("Part of raids in \(raid.expansion.name)")
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(raid.raidName)")
                }
//                ToolbarItemGroup(placement: .primaryAction) {
//                    Button("Print Data") {
//                        print(raid)
//                    }.padding()
//                }
            }
            
        }
    }
    
    func encounterDownloaded(for id: Int) -> Bool {
        guard let _ = gameData.raidEncounters.first(where: { (enc) -> Bool in
            enc.id == id
        }) else {
            print(id)
            downloadEncountersLoot()
            return false
        }
        return true
        
    }
    
    func selectEncounter(with id: Int) -> JournalEncounter {
        
        guard let boss = gameData.raidEncounters.first(where: { (enc) -> Bool in
            enc.id == id
        }) else {
            return gameData.raidEncounters.first!
        }
        return boss
    }
    
    func selectHighestMode(modes: [RaidEncountersForCharacter]) -> [RaidEncountersForCharacter] {
        return [modes.last!]
    }
    
    func downloadEncountersLoot(){
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/search/journal-encounter"
        let requestUrlSearchElement = "?instance.id=\(raid.id)"
        let requestUrlIdentifiablePart = requestUrlAPIHost + requestUrlAPIFragment + requestUrlSearchElement
        let URLIdentifier = URL(string: requestUrlIdentifiablePart)!
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: requestUrlIdentifiablePart, maximumAgeInDays: 90) {
            decodeEncountersData(savedData.data!)
            return
        }
        
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "static-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlIdentifiablePart +
                                    "&namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let data = data {
                self.decodeEncountersData(data, fromURL: URLIdentifier)
            }
            if let error = error {
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    private func decodeEncountersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            let dataResponse = try decoder.decode(JournalEncounterSearch.self, from: data)
            let wrapper = dataResponse.results
            var results: [JournalEncounter] = []
            
            wrapper.forEach { (wrapper) in
                results.append(wrapper.data)
            }
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            DispatchQueue.main.async {
                results.forEach { (DREncounter) in
                    if !gameData.raidEncounters.contains(DREncounter) {
                        gameData.raidEncounters.append(DREncounter)
                    }
                }
                gameData.raidEncounters.sort()
            }
            
            
        } catch {
            print(error)
        }
    }
    
}
