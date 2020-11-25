//
//  RandomRaidWidget.swift
//  Random Raid Widget
//
//  Created by Mikolaj Lukasik on 23/11/2020.
//

import WidgetKit
import SwiftUI

struct RaidEntry: TimelineEntry {
    var date: Date
    let raid: RaidsSuggestedForCharacter
    
}

struct Provider: TimelineProvider {
    @AppStorage(UserDefaultsKeys.raidSuggestions, store: UserDefaults(suiteName: UserDefaultsKeys.appUserGroup))
    var raidSuggestionsData: Data = Data()
    
    func placeholder(in context: Context) -> RaidEntry {
        let finalSuggestion = RaidsSuggestedForCharacter(
            characterID: 0,
            characterName: "Character",
            characterLevel: 60,
            characterRealmSlug: "",
            characterAvatarURI: "",
            characterFaction: FactionType.neutral,
            raids: []
        )
        
        let entry = RaidEntry(date: Date(), raid: finalSuggestion)
        
        return entry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RaidEntry) -> Void) {
        guard let allSuggestions = try? JSONDecoder().decode([RaidsSuggestedForCharacter].self, from: raidSuggestionsData) else { return }
        
        guard let suggestedCharacter = allSuggestions.randomElement() else { return }
        
        let raidToDo = suggestedCharacter.raids.isEmpty ? [] : [suggestedCharacter.raids.randomElement()!]
        
        let finalSuggestion = RaidsSuggestedForCharacter(
            characterID: suggestedCharacter.characterID,
            characterName: suggestedCharacter.characterName,
            characterLevel: suggestedCharacter.characterLevel,
            characterRealmSlug: suggestedCharacter.characterRealmSlug,
            characterAvatarURI: suggestedCharacter.characterAvatarURI,
            characterFaction: suggestedCharacter.characterFaction,
            raids: raidToDo
        )
        
        let entry = RaidEntry(date: Date(), raid: finalSuggestion)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RaidEntry>) -> Void) {
        guard let allSuggestions = try? JSONDecoder().decode([RaidsSuggestedForCharacter].self, from: raidSuggestionsData) else { return }
        
        
        var allRaids: [RaidsSuggestedForCharacter] = []
        
        for character in allSuggestions {
            for raid in character.raids {
                let currentSuggestion = RaidsSuggestedForCharacter(
                    characterID: character.characterID,
                    characterName: character.characterName,
                    characterLevel: character.characterLevel,
                    characterRealmSlug: character.characterRealmSlug,
                    characterAvatarURI: character.characterAvatarURI,
                    characterFaction: character.characterFaction,
                    raids: [raid]
                )
                allRaids.append(currentSuggestion)
            }
        }
        
        allRaids.shuffle()
        
        var allEntries: [RaidEntry] = []
        
        
        let currentDate = Date()
        for hourOffset in 0 ..< (allRaids.count - 1) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = RaidEntry(date: entryDate, raid: allRaids[hourOffset])
            allEntries.append(entry)
        }
        let timeline = Timeline(entries: allEntries, policy: .atEnd)
        
        completion(timeline)
    }
    
    typealias Entry = RaidEntry
    
}

struct Random_Raid_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetLogic(container: entry.raid)
    }
}

@main
struct RandomRaidWidget: Widget {
    let kind: String = "com.mlukasik.WoW-Helper.widgetKind.RandomRaidWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            Random_Raid_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Random raid")
        .description("Shows a random raid from all available for your characters.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        
    }
}

struct Random_Raid_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Random_Raid_WidgetEntryView(entry: RaidEntry(date: Date(), raid: Placeholders.placeholder))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        Random_Raid_WidgetEntryView(entry: RaidEntry(date: Date(), raid: Placeholders.placeholder))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        Random_Raid_WidgetEntryView(entry: RaidEntry(date: Date(), raid: Placeholders.placeholder))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

struct Placeholders {
    static let placeholder = RaidsSuggestedForCharacter(
        characterID: 0,
        characterName: "Character",
        characterLevel: 60,
        characterRealmSlug: "",
        characterAvatarURI: "",
        characterFaction: FactionType.neutral,
        raids: []
    )
}


