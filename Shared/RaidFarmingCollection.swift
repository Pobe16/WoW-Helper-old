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
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    
    @State var dataCreationDate: String = "N/A"
    
    @State var errorText: String?
    
    @State var characterEncounters: CharacterRaidEncounters?
    
    @State var raidDataFilledAndSorted: RaidDataFilledAndSorted? = nil
    
    @Binding var raidFarmingOptions: Int
    
    @State var showOptionsSheet: Bool = false
    
    let character: CharacterInProfile
    let data = (1...10).map { CGFloat($0) }

    let columns = [
        GridItem(.adaptive(minimum: 240), spacing: 0)
    ]
    
    var body: some View {
        ScrollView {
            if raidDataFilledAndSorted != nil {
//                LazyVGrid(columns: columns, spacing: 30, pinnedViews: [.sectionHeaders]) {
                LazyVGrid(columns: columns, spacing: 30) {
                    
                    ForEach(raidDataFilledAndSorted!.raidsCollection){ collection in
                        if collection.raids.count > 0 {
                            RaidFarmSection(collection: collection, faction: character.faction)
                        }
                    }
                    
                        
                    
                }
//                .padding()
                HStack {
                    Spacer()
                    Text("Last refreshed: \(dataCreationDate)")
                    Spacer()
                }.padding(.bottom)
            } else if errorText != nil {
                Text("\(errorText ?? "Unknown Error")")
            } else {
                ProgressView{}
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear {
            downloadRaidEncounters()
        }
        .onChange(of: raidFarmingOptions) { (value) in
            downloadRaidEncounters()
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
    
    func downloadRaidEncounters() {
        let levelRequiredForRaiding = gameData.expansions.count == 8 ? 60 : 30
        guard character.level >= levelRequiredForRaiding else {
            errorText = "Character level too low. You need at least level \(levelRequiredForRaiding) to try and conquer the raids."
            return
        }
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: "APIRegionHost") as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment =
            "/profile/wow/character"    + "/" +
            character.realm.slug        + "/" +
            character.name.lowercased() + "/" +
            "encounters/raids"
            
        let strippedAPIUrl = requestUrlAPIHost + requestUrlAPIFragment
        
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: strippedAPIUrl, maximumAgeInDays: 0.0416) {
            
            setDataCreationDate(to: savedData.creationDate!)
            
            decodeEncountersData(savedData.data!)
            
            return
        }
        
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
        task?.resume()
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
            
            characterEncounters = dataResponse
            combineCharacterEncountersWithData()

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
        let combinedRaidInfo = raidDataManipulator.createFullRaidData(using: characterEncounters, with: gameData, filter: options)
        
        DispatchQueue.main.async {
            withAnimation {
                raidDataFilledAndSorted = RaidDataFilledAndSorted(basedOn: combinedRaidInfo, for: character)
            }
        }
        
        
    }
}



#if DEBUG
struct RaidFarmingCollection_Previews: PreviewProvider {
    static var previews: some View {
        RaidFarmingCollection(raidFarmingOptions: .constant(1), character: placeholders.characterInProfile)
        
        RaidFarmingCollection(raidFarmingOptions: .constant(1), character: placeholders.characterInProfile)
        .previewLayout(.fixed(width: 320, height: 568))
        .previewDisplayName("iPhone SE 1st gen")
//
//        RaidFarmingCollection(character: placeholders.characterInProfile)
//        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
//        .previewDisplayName("iPhone 8")
//
//        RaidFarmingCollection(character: placeholders.characterInProfile)
//        .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
//        .previewDisplayName("iPhone 11 Pro Max")
    }
}
#endif
