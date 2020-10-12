//
//  FarmingCollection.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 28/08/2020.
//

import SwiftUI

enum RaidFarmingOptions: Hashable {
    case highest
    case all
    case noLfr
}

struct RaidFarmingCollection: View {
    @EnvironmentObject var farmOrder: FarmCollectionsOrder
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    
    @State var dataCreationDate: String = "N/A"
    
    @State var errorText: String?
    
    @State var characterEncounters: CharacterRaidEncounters? = nil
    
    @State var raidDataFilledAndSorted: RaidDataFilledAndSorted? = nil
    
    @Binding var raidFarmingOptions: Int
    
    let character: CharacterInProfile

    let columns = [
        GridItem(.adaptive(minimum: 240), spacing: 0)
    ]
    
    var body: some View {
        ScrollView {
            if raidDataFilledAndSorted != nil {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(raidDataFilledAndSorted!.raidsCollection, id: \.id){ collection in
                        if collection.raids.count > 0 {
                            Section(header: RaidFarmHeader(headerText: collection.name, faction: character.faction) ) {
                                ForEach(collection.raids, id: \.raidId) { raid in
                                    CharacterRaidTile(raid: raid, character: character)
                                }
                            }
                        }
                    }
                }.padding()
                HStack {
                    Spacer()
                    VStack {
                        Text("Last refreshed: \(dataCreationDate)")
                        Button {
                            loadEncounters(refresh: true)
                        } label: {
                            Label("Refresh", systemImage: "arrow.counterclockwise")
                        }
                        .padding(.top)
                    }
                    Spacer()
                }.padding(.vertical)
            } else if errorText != nil {
                Text("\(errorText ?? "Unknown Error")")
            } else {
                ProgressView{}
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear {
            loadEncounters()
        }
        .onChange(of: raidFarmingOptions) { (value) in
            loadEncounters()
        }
    }
    
    func setDataCreationDate(to date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        let dateString = dateFormatter.string(from: date)
        dataCreationDate = dateString
    }
    
    func loadEncounters(refresh: Bool = false) {
        let levelRequiredForRaiding = 30
        guard character.level >= levelRequiredForRaiding else {
            errorText = "Character level too low. You need at least level \(levelRequiredForRaiding) to try and conquer the raids."
            return
        }
        
        guard let GDCharacterEncounters = gameData.characterRaidEncounters.first(where: { (encounters) -> Bool in
            encounters.character.id == character.id
        }) else {
            downloadRaidEncounters(refresh: refresh)
            return
        }
        
        DispatchQueue.main.async {
            withAnimation {
                characterEncounters = GDCharacterEncounters
            }
            combineCharacterEncountersWithData()
        }
    }
    
    func downloadRaidEncounters(refresh: Bool = false) {
        
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment =
            "/profile/wow/character"    + "/" +
            character.realm.slug        + "/" +
            character.name.lowercased() + "/" +
            "encounters/raids"
            
        let strippedAPIUrl = requestUrlAPIHost + requestUrlAPIFragment
        
        let daysNeededForRefresh: Double = refresh ? 0.0 : 0.0416
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: daysNeededForRefresh) {
            
            setDataCreationDate(to: savedData.creationDate!)
            
            decodeEncountersData(savedData.data!)
            
            return
        }
        
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "profile-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? EuropeanLocales.BritishEnglish
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
//        print(fullRequestURL)
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data {
                
//                print(data)
                setDataCreationDate(to: Date())
                
                decodeEncountersData(data, fromURL: fullRequestURL)

            } else {
                if let error = error {
                    // something went wrong, check the error
                    print("error")
                    print(error.localizedDescription)
                }
                if let response = response as? HTTPURLResponse {
                    
                    print(response.statusString)
                }
            }
        }
        task.resume()
    }
    
    func decodeEncountersData(_ data: Data, fromURL url: URL? = nil) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        do {
            let dataResponse = try decoder.decode(CharacterRaidEncounters.self, from: data)
            
            if let url = url {
                JSONCoreDataManager.shared.saveJSON(data, withURL: url)
            }
            DispatchQueue.main.async {
                withAnimation {
                    characterEncounters = dataResponse
                    
                    if gameData.characterRaidEncounters.filter({ (GDEncounter) -> Bool in
                        GDEncounter.character.id == dataResponse.character.id
                    }).count == 0 {
                        gameData.characterRaidEncounters.append(dataResponse)
                    }
                }
                
                combineCharacterEncountersWithData()
            }

        } catch {
            print(error)
        }
    }
    
    func combineCharacterEncountersWithData() {
        var options: RaidFarmingOptions
        switch raidFarmingOptions {
        case 1:
            options = .highest
        case 2:
            options = .all
        case 3:
            options = .noLfr
        default:
            options = .highest
        }
        
        guard gameData.raids.count > 0 else { return }
        let raidDataManipulator = RaidDataHelper()
        let combinedRaidInfo = raidDataManipulator.createFullRaidData(using: characterEncounters, with: gameData, filter: options, filterForFaction: character.faction)
        
        let allDataCombined = RaidDataFilledAndSorted(basedOn: combinedRaidInfo, for: character, farmingOrder: farmOrder)
        
        DispatchQueue.main.async {
            withAnimation {
                raidDataFilledAndSorted = allDataCombined
            }
        }
        
        
    }
}
