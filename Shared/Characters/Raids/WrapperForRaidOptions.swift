//
//  WrapperForRaidFarming.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 03/09/2020.
//

import SwiftUI

struct WrapperForRaidOptions: View {
    let character: CharacterInProfile
    @State var raidFarmingOptions: Int = 1
//    @State var popOverVisible = false
    
    @State private var users = ["Paul", "Taylor", "Adele"]
    
    #if os(iOS)
    let raidSettingPlacement: ToolbarItemPlacement = .primaryAction
    #elseif os(macOS)
    let raidSettingPlacement: ToolbarItemPlacement = .confirmationAction
    #endif
    
    
    
    var body: some View {
        RaidFarmingCollection(raidFarmingOptions: $raidFarmingOptions, character: character)
        .onAppear( perform: { loadOptionsSelection() } )
        .toolbar {
            ToolbarItem(placement: raidSettingPlacement) {
                Menu {
                    Section(header: Text("Raid Modes")) {
                        Picker(selection: $raidFarmingOptions, label: Text("Raid options")) {
                            Text("Just Mythic").tag(1)
                            Text("All modes").tag(2)
                            Text("No LFR").tag(3)
                        }
                    }
                }
                label: {
                    Label("Raid Settings", systemImage: "gear")
                        .font(.title3)
                }
                
            }
        }
        .onChange(of: raidFarmingOptions) { (value) in
            saveOptionsSelection(value)
        }
    }
    
    func loadOptionsSelection() {
        let UDKey = "raidFilteringOptions"
        let option = UserDefaults.standard.integer(forKey: UDKey)
        raidFarmingOptions = option == 0 ? 1 : option
        
        
    }
    
    func saveOptionsSelection(_ value: Int) {
        let UDKey = "raidFilteringOptions"
        
        UserDefaults.standard.setValue(value, forKey: UDKey)
    }
    
}

