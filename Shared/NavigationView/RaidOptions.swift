//
//  RaidOptions.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 05/09/2020.
//

import SwiftUI

struct RaidOptions: View {
    @EnvironmentObject var farmOrder: FarmCollectionsOrder
    @State var raidFarmingOptions: Int = 1
    
    
    
    var body: some View {
        
        VStack{
            List(){
                ForEach(farmOrder.options) { collection in
                    Text("\(collection.order+1). \(collection.name)")
                }
                .onMove(perform: move)
            }
            .listStyle(GroupedListStyle())
            .frame(height: 300)
            .padding()
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.destructiveAction){
                    EditButton()
//                    Text("12")
                }
            }
            
            Section(header: Text("Difficulty")) {
                Picker(selection: $raidFarmingOptions, label: Text("")) {
                    Text("Just Mythic").tag(1)
                    Text("All modes").tag(2)
                    Text("No LFR").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: raidFarmingOptions) { (value) in
                    saveOptionsSelection(value)
                }
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Raid settings")
            }
        }
        .onAppear{ loadOptionsSelection() }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        farmOrder.options.move(fromOffsets: source, toOffset: destination)
        farmOrder.options.forEach { (item) in
            let newOrder = farmOrder.options.firstIndex(of: item)
            if newOrder != nil {
                farmOrder.options[newOrder!].order = newOrder!
            }
        }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(farmOrder.options) {
            UserDefaults.standard.set(encoded, forKey: "RaidCollectionsOrder")
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

struct RaidOptions_Previews: PreviewProvider {
    static var previews: some View {
        RaidOptions()
            .environmentObject(FarmCollectionsOrder())
    }
}
