//
//  RaidDataFilledAndSorted.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 01/09/2020.
//

import Foundation

struct NamedRaidCollection: Comparable, Identifiable {
    static func < (lhs: NamedRaidCollection, rhs: NamedRaidCollection) -> Bool {
        lhs.id < rhs.id
    }
    
    public let id: Int
    public let name: String
    public let raids: [CombinedRaidWithEncounters]
}

struct RaidDataFilledAndSorted {
    private let currentContent: [CombinedRaidWithEncounters]
    private let hardFarm: [CombinedRaidWithEncounters]
    private let comfortFarm: [CombinedRaidWithEncounters]
    private let completed: [CombinedRaidWithEncounters]
    private let ignored: [CombinedRaidWithEncounters]
    public var raidsCollection: [NamedRaidCollection]
    
    init(basedOn characterEncounters: [CombinedRaidWithEncounters], for character: CharacterInProfile, farmingOrder: FarmCollectionsOrder) {
        let helper = RaidDataHelper()
        let currentLevel = character.level
        var allRaids = characterEncounters
        
        var raidsToSave: [NamedRaidCollection] = []
        
        var raidsToBeIgnored: [CombinedRaidWithEncounters] = []
        
        completed = allRaids.filter({ (raid) -> Bool in
            helper.isWholeRaidCleared(raid)
        }).sorted(by: helper.raidSort)
        
        completed.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        let completedOrder = farmingOrder.options.first { type -> Bool in
            type.name == "Completed"
        }?.order
        
        raidsToSave.append(
            NamedRaidCollection(
                id: completedOrder ?? 4,
                name: "Completed",
                raids: completed
            )
        )
          
        currentContent = allRaids.filter({ (raid) -> Bool in
            raid.minimumLevel == currentLevel
        }).sorted(by: helper.raidSort)
        
        currentContent.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        let currentOrder = farmingOrder.options.first { type -> Bool in
            type.name == "Current content"
        }?.order
        
        raidsToSave.append(
            NamedRaidCollection(
                id: currentOrder ?? 3,
                name: "Current content",
                raids: currentContent
            )
        )
        
        
        hardFarm = allRaids.filter({ (raid) -> Bool in
            currentLevel > raid.minimumLevel && currentLevel - raid.minimumLevel < 11
        }).sorted(by: helper.raidSort)
        
        hardFarm.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        let hardOrder = farmingOrder.options.first { type -> Bool in
            type.name == "Hard farm"
        }?.order
        
        raidsToSave.append(
            NamedRaidCollection(
                id: hardOrder ?? 1,
                name: "Hard farm",
                raids: hardFarm
            )
        )
        
        comfortFarm = allRaids.filter({ (raid) -> Bool in
            currentLevel > raid.minimumLevel
        }).sorted(by: helper.raidSort)
        
        
        comfortFarm.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        let easyOrder = farmingOrder.options.first { type -> Bool in
            type.name == "Easy farm"
        }?.order
        
        raidsToSave.append(
            NamedRaidCollection(
                id: easyOrder ?? 2,
                name: "Easy farm",
                raids: comfortFarm
            )
        )
        
        raidsToBeIgnored.append(contentsOf: allRaids)
        
        ignored = raidsToBeIgnored.sorted(by: helper.raidSort)
        
        let ignoredOrder = farmingOrder.options.first { type -> Bool in
            type.name == "Ignored"
        }?.order
        
        raidsToSave.append(
            NamedRaidCollection(
                id: ignoredOrder ?? 100,
                name: "Ignored",
                raids: ignored
            )
        )
        
        raidsCollection = raidsToSave.sorted()
    }
    
    mutating func prepareForSummary() {
        self.raidsCollection.removeAll { (namedCollection) -> Bool in
            namedCollection.name == "Ignored"
        }
        self.raidsCollection.removeAll { (namedCollection) -> Bool in
            namedCollection.name == "Completed"
        }
    }
}
