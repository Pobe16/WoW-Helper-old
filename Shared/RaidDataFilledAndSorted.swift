//
//  RaidDataFilledAndSorted.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 01/09/2020.
//

import Foundation

struct RaidDataFilledAndSorted {
    public let currentContent: [CombinedRaidWithEncounters]
    public let hardFarm: [CombinedRaidWithEncounters]
    public let comfortFarm: [CombinedRaidWithEncounters]
    public let completed: [CombinedRaidWithEncounters]
    public let ignored: [CombinedRaidWithEncounters]
    
    init(basedOn characterEncounters: [CombinedRaidWithEncounters], for character: CharacterInProfile) {
        let helper = RaidDataHelper()
        let currentLevel = character.level
        var allRaids = characterEncounters
        
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
        
        raidsToBeIgnored.append(contentsOf: allRaids)
        
        ignored = raidsToBeIgnored
    }
}
