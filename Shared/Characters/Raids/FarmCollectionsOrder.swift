//
//  FarmCollectionsOrder.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 05/09/2020.
//

import Foundation

struct RaidCollectionsNames: Hashable, Identifiable, Comparable, Codable {
    static func < (lhs: RaidCollectionsNames, rhs: RaidCollectionsNames) -> Bool {
        lhs.order < rhs.order
    }
    
    var id: UUID = UUID()
    var order: Int
    var name: String
}

class FarmCollectionsOrder: ObservableObject {
    
    @Published var options: [RaidCollectionsNames]
    
    init() {
        let decoder = JSONDecoder()
        guard let savedData = UserDefaults.standard.object(forKey: "RaidCollectionsOrder") as? Data,
              let loadedData = try? decoder.decode([RaidCollectionsNames].self, from: savedData)
        else {
            
            var collection: [RaidCollectionsNames] = []
            collection.append(
                RaidCollectionsNames(
                    order: 0,
                    name: "Hard farm"
                )
            )
            collection.append(
                RaidCollectionsNames(
                    order: 1,
                    name: "Easy farm"
                )
            )
            collection.append(
                RaidCollectionsNames(
                    order: 2,
                    name: "Current content"
                )
            )
            collection.append(
                RaidCollectionsNames(
                    order: 3,
                    name: "Completed"
                )
            )
            collection.append(
                RaidCollectionsNames(
                    order: 4,
                    name: "Ignored"
                )
            )
            
            options = collection
            return
        }
        options = loadedData
    }
}
