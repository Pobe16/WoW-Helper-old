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
    public let raidsCollection: [NamedRaidCollection]
    
    init(basedOn characterEncounters: [CombinedRaidWithEncounters], for character: CharacterInProfile) {
        let helper = RaidDataHelper()
        let currentLevel = character.level
        var allRaids = characterEncounters
        
        var raidsToSave: [NamedRaidCollection] = []
        
        var raidsToBeIgnored: [CombinedRaidWithEncounters] = []
        
        completed = allRaids.filter({ (raid) -> Bool in
            helper.isWholeRaidCleared(raid)
        }).sorted(by: { (lhs, rhs) -> Bool in
            lhs.raidId > rhs.raidId
        })
        
        completed.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        raidsToSave.append(
            NamedRaidCollection(
                id: 3,
                name: "Completed",
                raids: completed
            )
        )
          
        currentContent = allRaids.filter({ (raid) -> Bool in
            raid.minimumLevel == currentLevel
        }).sorted(by: { (lhs, rhs) -> Bool in
            lhs.raidId > rhs.raidId
        })
        
        currentContent.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        raidsToSave.append(
            NamedRaidCollection(
                id: 0,
                name: "Current content",
                raids: currentContent
            )
        )
        
        
        hardFarm = allRaids.filter({ (raid) -> Bool in
            currentLevel > raid.minimumLevel && currentLevel - raid.minimumLevel < 11
        }).sorted(by: { (lhs, rhs) -> Bool in
            lhs.raidId > rhs.raidId
        })
        
        hardFarm.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        raidsToSave.append(
            NamedRaidCollection(
                id: 1,
                name: "Hard farm",
                raids: hardFarm
            )
        )
        
        comfortFarm = allRaids.filter({ (raid) -> Bool in
            currentLevel > raid.minimumLevel
        }).sorted(by: { (lhs, rhs) -> Bool in
            lhs.raidId > rhs.raidId
        })
        
        comfortFarm.forEach { (raid) in
            let raidIndex = allRaids.firstIndex(of: raid)
            
            guard let index = raidIndex else { return }
            allRaids.remove(at: index)
        }
        
        raidsToSave.append(
            NamedRaidCollection(
                id: 2,
                name: "Easy farm",
                raids: comfortFarm
            )
        )
        
        raidsToBeIgnored.append(contentsOf: allRaids)
        
        ignored = raidsToBeIgnored
        
        raidsToSave.append(
            NamedRaidCollection(
                id: 100,
                name: "Ignored",
                raids: ignored
            )
        )
        
        raidsCollection = raidsToSave
    }
}
