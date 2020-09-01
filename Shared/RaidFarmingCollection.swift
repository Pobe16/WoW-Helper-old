//
//  FarmingCollection.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 28/08/2020.
//

import SwiftUI

struct RaidFarmingCollection: View {
    @EnvironmentObject var authorization: Authentication
    @EnvironmentObject var gameData: GameData
    
    @State var errorDescription: String?
    
    @State var dataCreationDate: String = "N/A"
    
    @State var characterEncounters: CharacterRaidEncounters?
    
    @State var combinedRaidsWithEncountersInfo: [CombinedRaidWithEncounters] = []
    
    let character: CharacterInProfile
    let data = (1...10).map { CGFloat($0) }

    let columns = [
        GridItem(.adaptive(minimum: 180), spacing: 30)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 30, pinnedViews: [.sectionHeaders]) {
                
                Section(header:
                            HStack{
//                                Spacer()
                                Text("Section 1")
                                    .font(.title)
                                    .padding()
                                    .padding(.leading, 15)
                                Spacer()
                            }
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(30)
                ) {
                    ForEach(combinedRaidsWithEncountersInfo, id: \.self) { raid in
                        ZStack {
                            Color(
                                UIColor(
                                    red: CGFloat.random(in: 0...1),
                                    green: CGFloat.random(in: 0...1),
                                    blue: CGFloat.random(in: 0...1),
                                    alpha: 1.0)
                            )
                            Text("\(raid.raidName)")
                                .padding()
                        }
                        .frame(height: 180)
                        .cornerRadius(30)
                    }
                }
            }
            .padding()
            HStack {
                Spacer()
                Text("Last refreshed: \(dataCreationDate)")
                Spacer()
            }.padding(.bottom)
        }
        .onAppear {
            downloadRaidEncounters()
        }
                
    }
    
    func setDataCreationDate(to date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
//        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.locale = Locale.current
        let dateString = dateFormatter.string(from: date)
        dataCreationDate = dateString
    }
    
    func downloadRaidEncounters() {
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
        print(fullRequestURL)
        
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
            fillTheGapsInEncounters()

        } catch {
            print(error)
        }
    }
    
    func fillTheGapsInEncounters(){
        guard gameData.raids.count > 0,
              let downloadedCharacterEncounters = characterEncounters else {
            return
        }
        var strippedRaids: [RaidInstancesInCharacterEncounters] = []
        downloadedCharacterEncounters.expansions?.forEach({ (expansion) in
                strippedRaids.append(contentsOf: expansion.instances)
        })
        
        gameData.raids.forEach { GDRaid in
            var currentRaid: CombinedRaidWithEncounters
            
            if let playerRaid = strippedRaids.first(where: { (playerInstance) -> Bool in
                return playerInstance.instance.id == GDRaid.id
            }) {
                var allRaidModes: [RaidEncountersForCharacter] = []
                GDRaid.modes.forEach { (mode) in
                    
                    if let playerRaidMode = playerRaid.modes.first(where: { (encounter) -> Bool in
                        encounter.difficulty == mode.mode
                    }) {
                        var instanceEncounters: [EncounterPerBossPerCharacter] = []
                        
                        GDRaid.encounters.forEach { (GDEncounter) in
                            
                            var encounterToAdd: EncounterPerBossPerCharacter
                            
                            if let playerEncounter = playerRaidMode.progress.encounters.first(where: { (boss) -> Bool in
                                boss.encounter.id == GDEncounter.id
                            }) {
                                encounterToAdd = playerEncounter
                            } else {
                                encounterToAdd = createEmptyBoss(for: GDEncounter)
                            }
                            
                            instanceEncounters.append(encounterToAdd)
                                                        
                        }
                        
                        let currentRaidMode =
                            RaidEncountersForCharacter(
                                difficulty: mode.mode,
                                status: playerRaidMode.status,
                                progress:
                                    InstanceProgress(
                                        completedCount: playerRaidMode.progress.completedCount,
                                        totalCount: playerRaidMode.progress.totalCount,
                                        encounters: instanceEncounters
                                    )
                            )
                        
                        allRaidModes.append(currentRaidMode)
                            
                    } else {
                        let currentRaidMode = createEmptyInstanceMode(for: GDRaid, withMode: mode.mode)
                        allRaidModes.append(currentRaidMode)
                    }
                    
                }
                currentRaid =
                    CombinedRaidWithEncounters(
                        raidId: GDRaid.id,
                        raidName: GDRaid.name,
                        description: GDRaid.description,
                        minimumLevel: GDRaid.minimumLevel,
                        expansion: GDRaid.expansion,
                        media: GDRaid.media,
                        modes: GDRaid.modes,
                        records: allRaidModes
                    )
            } else {
                currentRaid = createNewEmptyRaid(for: GDRaid)
            }
            DispatchQueue.main.async {
                withAnimation {
                    combinedRaidsWithEncountersInfo.append(currentRaid)
                }
            }
        }
    }
    
    func createEmptyBoss(for encounter: EncounterIndex) -> EncounterPerBossPerCharacter {
        let emptyEncounter =
            EncounterPerBossPerCharacter(
                completedCount: 0,
                encounter:
                    EncounterIndex(
                        key: encounter.key,
                        id: encounter.id,
                        name: encounter.name
                    ),
                lastKillTimestamp: nil
            )
        return emptyEncounter
    }
    
    func createEmptyInstanceMode(for instance: InstanceJournal, withMode mode: InstanceModeName) -> RaidEncountersForCharacter {
        var encounters: [EncounterPerBossPerCharacter] = []
        instance.encounters.forEach { (GDEncounter) in
            encounters.append(createEmptyBoss(for: GDEncounter))
        }
        
        let emptyInstance =
            RaidEncountersForCharacter(
                difficulty: mode,
                status:
                    InstanceStatus(
                        type: "NEW",
                        name: "New"
                    ),
                progress:
                    InstanceProgress(
                        completedCount: 0,
                        totalCount: 0,
                        encounters: encounters
                    )
            )
        return emptyInstance
    }
    
    func createNewEmptyRaid(for instance: InstanceJournal) -> CombinedRaidWithEncounters {
        var allRaids: [RaidEncountersForCharacter] = []
        instance.modes.forEach { (mode) in
            let emptyInstanceMode = createEmptyInstanceMode(for: instance, withMode: mode.mode)
            allRaids.append(emptyInstanceMode)
        }
        let currentRaid =
            CombinedRaidWithEncounters(
                raidId: instance.id,
                raidName: instance.name,
                description: instance.description,
                minimumLevel: instance.minimumLevel,
                expansion: instance.expansion,
                media: instance.media,
                modes: instance.modes,
                records: allRaids
            )
        return currentRaid
    }
}

#if DEBUG
struct RaidFarmingCollection_Previews: PreviewProvider {
    static var previews: some View {
        RaidFarmingCollection(character: placeholders.characterInProfile)
        
        RaidFarmingCollection(character: placeholders.characterInProfile)
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
