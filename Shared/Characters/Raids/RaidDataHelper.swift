//
//  RaidDataManipulator.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 01/09/2020.
//

import Foundation

struct RaidDataHelper {
    public func createFullRaidData(using characterEncounters: CharacterRaidEncounters?, with gameData: GameData, filter options: RaidFarmingOptions) -> [CombinedRaidWithEncounters] {
        
        var strippedRaids: [RaidInstancesInCharacterEncounters] = []
        if characterEncounters != nil {
            characterEncounters?.expansions?.forEach({ (expansion) in
                    strippedRaids.append(contentsOf: expansion.instances)
            })
        }
        
        var allFilledRaids: [CombinedRaidWithEncounters] = []
        
        gameData.raids.forEach { GDRaid in
            var currentRaid: CombinedRaidWithEncounters
            
            if let playerRaid = strippedRaids.first(where: { (playerInstance) -> Bool in
                return playerInstance.instance.id == GDRaid.id
            }) {
                var allRaidModes: [RaidEncountersForCharacter] = []
                
                let filteredModes: [InstanceMode] = filterRaidModes(forModes: GDRaid.modes, by: options)
                
                filteredModes.forEach { (mode) in
                    
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
                        modes: filteredModes,
                        records: allRaidModes
                    )
            } else {
                currentRaid = createNewEmptyRaid(for: GDRaid, filteredBy: options)
            }
            
            allFilledRaids.append(currentRaid)
                
        }
        return allFilledRaids
    }
    
    private func filterRaidModes(forModes modes: [InstanceMode], by options: RaidFarmingOptions) -> [InstanceMode] {
        guard modes.count > 1 else {
            return modes
        }
        
        switch options {
        case .all:
            return modes
        case .noLfr:
            return modes.filter { (mode) -> Bool in
                return mode.mode.type != "LFR"
            }
        case .highest:
            var highestMode: [InstanceMode] = []
            
            highestMode.append(contentsOf: modes.filter { (mode) -> Bool in
                return mode.mode.type == "MYTHIC"
            } )
            
            guard highestMode.count == 0 else {
                return highestMode
            }
            
            highestMode.append(contentsOf: modes.filter { (mode) -> Bool in
                return mode.mode.type == "LEGACY_25_MAN_HEROIC"
            } )
            
            guard highestMode.count == 0 else {
                return highestMode
            }
            
            highestMode.append(contentsOf: modes.filter { (mode) -> Bool in
                return mode.mode.type == "LEGACY_10_MAN_HEROIC"
            } )
            
            guard highestMode.count == 0 else {
                return highestMode
            }
            
            highestMode.append(contentsOf: modes.filter { (mode) -> Bool in
                return mode.mode.type == "LEGACY_25_MAN"
            } )
            
            guard highestMode.count == 0 else {
                return highestMode
            }
            
            highestMode.append(contentsOf: modes.filter { (mode) -> Bool in
                return mode.mode.type == "LEGACY_10_MAN"
            } )
            
            guard highestMode.count == 0 else {
                return highestMode
            }
            
            highestMode.append(contentsOf: modes.filter { (mode) -> Bool in
                return mode.mode.type == "HEROIC"
            } )
            
            guard highestMode.count == 0 else {
                return highestMode
            }
            
            highestMode.append(contentsOf: modes.filter { (mode) -> Bool in
                return mode.mode.type == "NORMAL"
            } )
            
            guard highestMode.count == 0 else {
                return highestMode
            }
            
            return [modes.last!]
        }
        
    }
    
    private func createEmptyBoss(for encounter: EncounterIndex) -> EncounterPerBossPerCharacter {
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
    
    private func createEmptyInstanceMode(for instance: InstanceJournal, withMode mode: InstanceModeName) -> RaidEncountersForCharacter {
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
    
    private func createNewEmptyRaid(for instance: InstanceJournal, filteredBy options: RaidFarmingOptions) -> CombinedRaidWithEncounters {
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
                modes: filterRaidModes(forModes: instance.modes, by: options),
                records: allRaids
            )
        return currentRaid
    }
    
    public func dateOfNextWeeklyReset() -> Date {
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: "loginRegion")]
        
        var components = DateComponents()
        if regionShortCode == "eu" {
            // Wednesdays at 7:00 UTC
            components.hour = 7
            components.weekday = 4
        } else {
            // Tuesdaus at 15:00 UTC
            components.hour = 15
            components.weekday = 3
        }
        components.timeZone = TimeZone(abbreviation: "UTC")

        let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
        
        return date!
    }
    
    public func dateOfLastWeeklyReset() -> Date {
        let date = Calendar.current.date(byAdding: .day, value: -7, to: dateOfNextWeeklyReset())
        
        return date!
    }
    
    public func isLegacyModeCleared(for raidMode: RaidEncountersForCharacter) -> Bool {
        let lastReset = dateOfLastWeeklyReset()
        guard let encounter = raidMode.progress.encounters.last,
              let timestamp = encounter.lastKillTimestamp else { return false }
        return timestamp > lastReset
        
    }
    
    public func isModeCleared(for raidMode: RaidEncountersForCharacter) -> Bool {
        let lastReset = dateOfLastWeeklyReset()
        
        for encounter in raidMode.progress.encounters {
            guard let killTimestamp = encounter.lastKillTimestamp,
                  killTimestamp > lastReset else {
                return false
            }
            
        }
        return true
    }
    
    public func getNumberOfKilledBosses(for raidMode: RaidEncountersForCharacter) -> Int {
        let lastReset = dateOfLastWeeklyReset()
        var killedBosses = 0
        
        for encounter in raidMode.progress.encounters {
            if encounter.lastKillTimestamp != nil && encounter.lastKillTimestamp! > lastReset {
                killedBosses += 1
            }
        }
        return killedBosses
    }
    
    public func isWholeRaidCleared(_ raid: CombinedRaidWithEncounters) -> Bool {
        
        // the first two expansions (id 68 and 70) only have last boss in the player encounter, that's why we need a special legacy mode checker
        if raid.expansion.id < 72 {
            for raidMode in raid.records {
                guard isLegacyModeCleared(for: raidMode) else { return false }
            }
        } else {
            for raidMode in raid.records {
                guard isModeCleared(for: raidMode) else { return false}
            }
        }
        return true
    }
}
