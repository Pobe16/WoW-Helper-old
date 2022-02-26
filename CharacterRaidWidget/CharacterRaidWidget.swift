//
//  CharacterRaidWidget.swift
//  CharacterRaidWidget
//
//  Created by Mikolaj Lukasik on 24/11/2020.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = SimpleEntry(date: entryDate, configuration: configuration)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct CharacterRaidWidgetEntryView: View {
    @AppStorage(UserDefaultsKeys.raidSuggestions, store: UserDefaults(suiteName: UserDefaultsKeys.appUserGroup))
    var raidSuggestionsData: Data = Data()

    var entry: Provider.Entry

    var body: some View {
        WidgetLogic(container: getCharacterSuggestionFromIntent(entry))
    }

    func getCharacterSuggestionFromIntent(_ entry: Provider.Entry) -> RaidsSuggestedForCharacter? {
        guard let characterFromIntent = entry.configuration.character  else { return nil }
        guard characterFromIntent.characterID != nil else { return nil }

        let emptyCharacterSuggestion = RaidsSuggestedForCharacter(
            characterID: Int(truncating: characterFromIntent.characterID ?? 0),
            characterName: characterFromIntent.characterName ?? "",
            characterLevel: Int(truncating: characterFromIntent.characterLevel ?? 1),
            characterRealmSlug: characterFromIntent.characterRealm ?? "",
            characterAvatarURI: characterFromIntent.characterAvatarURI ?? "",
            characterFaction: FactionType.init(
                characterFromIntent.characterFaction ?? "NEUTRAL"
            ) ?? FactionType.neutral,
            raids: []
        )

        guard let finalSuggestion = getSuggestionFromUserDefaults(for: characterFromIntent) else {
            return emptyCharacterSuggestion
        }

        return finalSuggestion

    }

    func getSuggestionFromUserDefaults(for intentCharacter: WoWCharacter) -> RaidsSuggestedForCharacter? {
        guard let allSuggestions = try? JSONDecoder().decode(
            [RaidsSuggestedForCharacter].self,
            from: raidSuggestionsData
        ) else { return nil }
        guard let suggestionFromUD = allSuggestions.first(where: { (UDSuggestion) -> Bool in
            return  UDSuggestion.characterName == intentCharacter.characterName &&
                    UDSuggestion.characterID == Int(truncating: intentCharacter.characterID ?? -2137) &&
                    UDSuggestion.characterRealmSlug == intentCharacter.characterRealm
        }) else { return nil }
        guard let suggestedRaid = suggestionFromUD.raids.first else { return suggestionFromUD }

        let completeSuggestion = RaidsSuggestedForCharacter(
            characterID: suggestionFromUD.characterID,
            characterName: suggestionFromUD.characterName,
            characterLevel: suggestionFromUD.characterLevel,
            characterRealmSlug: suggestionFromUD.characterRealmSlug,
            characterAvatarURI: suggestionFromUD.characterAvatarURI ,
            characterFaction: suggestionFromUD.characterFaction,
            raids: [suggestedRaid]
        )

        return completeSuggestion
    }
}

@main
struct CharacterRaidWidget: Widget {
    let kind: String = "com.mlukasik.WoW-Helper.widgetKind.CharacterRaidWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CharacterRaidWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Suggested for character")
        .description("First raid to farm for character, you can customise the farming order in options.")
    }
}

struct CharacterRaidWidget_Previews: PreviewProvider {
    static var previews: some View {
        CharacterRaidWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
