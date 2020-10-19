//
//  RaidOptions.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 05/09/2020.
//

import SwiftUI

struct RaidOptions: View {
    @State var raidFarmingOptions: Int = 1
    
    #if os(iOS)
    var listStyle = InsetGroupedListStyle()
    #elseif os(macOS)
    var listStyle =  DefaultListStyle()
    #endif
    
    
    var body: some View {
        
        List(){
            
            Section(header: Text("Farming order").whiteTextWithBlackOutlineStyle()) {
                NavigationLink(destination:
                                FarmingOrder()) {
                    Text("Farming order")
                }
            }.padding(.horizontal)
            
            Section(header: Text("Difficulty").whiteTextWithBlackOutlineStyle()) {
                Picker(selection: $raidFarmingOptions, label: Text("")) {
                    Text("Highest").tag(1)
                    Text("All modes").tag(2)
                    Text("No LFR").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: raidFarmingOptions) { (value) in
                    saveOptionsSelection(value)
                }
            }.padding(.horizontal)
        }
        .padding(.horizontal)
        .listStyle(listStyle)
        .background(
            BackgroundTexture(texture: .ice, wall: .horizontal)
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Raid settings")
            }
        }
        .onAppear{ loadOptionsSelection() }
    }
    
    func loadOptionsSelection() {
        let option = UserDefaults.standard.integer(forKey: UserDefaultsKeys.raidFilteringOptions)
        raidFarmingOptions = option == 0 ? 1 : option
        
        
    }
    
    func saveOptionsSelection(_ value: Int) {
        UserDefaults.standard.setValue(value, forKey: UserDefaultsKeys.raidFilteringOptions)
    }
}

struct RaidOptions_Previews: PreviewProvider {
    static var previews: some View {
        RaidOptions()
            .previewDevice("iPhone SE (1st generation)")
            .environmentObject(FarmCollectionsOrder())
    }
}
