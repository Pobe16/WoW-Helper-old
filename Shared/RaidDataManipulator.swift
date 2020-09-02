//
//  RaidDataManipulator.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 01/09/2020.
//

import Foundation

struct RaidDataHelper {
    public func createFullRaidData(using characterEncounters: CharacterRaidEncounters?, with gameData: GameData) -> [CombinedRaidWithEncounters] {
        
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
            
            allFilledRaids.append(currentRaid)
                
        }
        return allFilledRaids
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
    
    private func createNewEmptyRaid(for instance: InstanceJournal) -> CombinedRaidWithEncounters {
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
