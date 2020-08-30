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
    
    @State var dataCreationDate: String = "Loading"
    
    @State var characterEncounters: CharacterRaidEncounters?
    
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
                    ForEach(data, id: \.self) { _ in
                        Color(
                            UIColor(
                                red: CGFloat.random(in: 0...1),
                                green: CGFloat.random(in: 0...1),
                                blue: CGFloat.random(in: 0...1),
                                alpha: 1.0)
                        )
                        .frame(height: 180)
                        .cornerRadius(30)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            downloadRaidEncounters()
        }
        .toolbar {
            ToolbarItem(placement: .status) {
                HStack{
                    Spacer()
                    Text("Last refreshed: \(dataCreationDate)")
                }
            }
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
                
            
            
        } catch {
            print(error)
        }
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
