//
//  FarmingOrder.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 29/09/2020.
//

import SwiftUI

struct FarmingOrder: View {
    @EnvironmentObject var gameData: GameData
    @EnvironmentObject var farmOrder: FarmCollectionsOrder

    #if os(iOS)
    var listStyle = InsetGroupedListStyle()
    #elseif os(macOS)
    var listStyle =  DefaultListStyle()
    #endif

    var body: some View {
        List {
            ForEach(farmOrder.options) { collection in
                Text("\(collection.order+1). \(collection.name)")
            }
            .onMove(perform: move)
        }
        .padding(.horizontal)
        .listStyle(listStyle)
        .background(
            BackgroundTexture(texture: .ice, wall: .horizontal)
                .edgesIgnoringSafeArea(.all)
        )
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .automatic) {
                EditButton()
            }
            #endif
            ToolbarItem(placement: .principal) {
                Text("Farming order")
            }
        }
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
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.RaidCollectionsOrder)
        }
        DispatchQueue.main.async {
            gameData.prepareSuggestedRaids()
        }
    }
}

struct FarmingOrder_Previews: PreviewProvider {
    static var previews: some View {
        FarmingOrder()
            .environmentObject(FarmCollectionsOrder())
    }
}
