//
//  FarmingCollection.swift
//  WoWHelper 
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
    
    @State var retries: Int = 0
    
    @State var characterEncounters: CharacterRaidEncounters? = nil
    
    @State var raidDataFilledAndSorted: RaidDataFilledAndSorted? = nil
    
    @Binding var raidFarmingOptions: Int
    
    let character: CharacterInProfile

    let columns = [
        GridItem(.adaptive(minimum: 240), spacing: 0)
    ]
    
    var body: some View {
        ScrollView {
            if character.level < 30 {
                HStack{
                    Text("Character level too low. You need at least level 30 to try and conquer the raids.")
                        .font(.title)
                        .padding()
                    Spacer()
                }
                .padding()
            } else if raidDataFilledAndSorted != nil {
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
                
            } else if errorText != nil {
                HStack{
                    Text("\(errorText ?? "Unknown error")")
                        .font(.title)
                        .padding()
                    Spacer()
                }
                .padding()
            } else {
                ProgressView{}
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .onAppear {
                        loadEncounters()
                    }
            }
            if (raidDataFilledAndSorted != nil || errorText != nil) && character.level >= 30 {
                HStack {
                    Spacer()
                    VStack {
                        if raidDataFilledAndSorted != nil {
                            Text("Last refreshed: \(dataCreationDate)")
                        }
                        Button {
                            retries = 0
                            updateEncounters()
                        } label: {
                            Label("Refresh", systemImage: "arrow.counterclockwise")
                        }
                        .padding(.top)
                    }
                    Spacer()
                }.padding(.vertical)
            }
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
    
    func updateEncounters() {
        gameData.reloadCharacterRaidEncounters(for: character)
        DispatchQueue.main.async {
            withAnimation {
                errorText = nil
                characterEncounters = nil
                raidDataFilledAndSorted = nil
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            loadEncounters()
        }
    }
    
    func loadEncounters(refresh: Bool = false) {
        
        guard let GDCharacterEncounters = gameData.characterRaidEncounters.first(where: { (encounters) -> Bool in
            encounters.character.id == character.id
        }) else {
            if retries < 2 {
                retries += 1
                updateEncounters()
            } else {
                errorText = "Problem loading character encounter data. You may try manually reloading with a button below. For characters you have not used in a long time, you might need to log in and out in game to refresh their data on Blizzard's servers."
            }
            return
        }
        
        DispatchQueue.main.async {
            withAnimation {
                characterEncounters = GDCharacterEncounters
            }
            checkDataCreationDate(for: GDCharacterEncounters)
            combineCharacterEncountersWithData()
        }
    }
    
    func checkDataCreationDate(for encounters: CharacterRaidEncounters) {
        guard let link = encounters._links else {
            print("no link")
            return
        }
        let urlString = link.`self`.href
        if let savedData = JSONCoreDataManager.shared.fetchJSONData(withName: urlString, maximumAgeInDays: 99999) {
            setDataCreationDate(to: savedData.creationDate!)
        } else {
            print("no date")
            return
            
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
            raidDataFilledAndSorted = allDataCombined
        }
        
        
    }
}
