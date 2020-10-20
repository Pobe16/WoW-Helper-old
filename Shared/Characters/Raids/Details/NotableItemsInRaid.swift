//
//  NotableItemsInRaid.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 27/09/2020.
//

import SwiftUI

struct NotableItemsInRaid: View {
    
    @EnvironmentObject var gameData: GameData
    
    let encounter: JournalEncounter
    
    @State var mounts: [ItemStub] = []
    @State var pets: [ItemStub] = []
    
    var body: some View {
        VStack {
            if mounts.count > 0 {
                Text("Mounts:")
                ForEach(mounts, id: \.id) { mount in
                    Text(mount.name.value)
                }
            } else {
                EmptyView()
            }
            if pets.count > 0 {
                Text("Pets:")
                ForEach(pets, id: \.id) { pet in
                    Text(pet.name.value)
                }
            } else {
                EmptyView()
            }
        }.onAppear{
            prepareLoot()
        }
    }
    
    func prepareLoot() {
        let loot = encounter.items
        var mountsInEncounter: [ItemStub] = []
        var petsInEncounter: [ItemStub] = []
        
        loot.forEach { (wrapper) in
            if gameData.mountItemsList.contains(where: { (mount) -> Bool in
                mount.itemID == wrapper.item.id
            }) {
                mountsInEncounter.append(wrapper.item)
            }
            if gameData.petItemsList.contains(where: { (pet) -> Bool in
                pet.itemID == wrapper.item.id
            }) {
                petsInEncounter.append(wrapper.item)
            }
        }
//        mountsInEncounter.forEach { (mount) in
//            print("CollectibleItem(id: \(mount.id), name: \"\(mount.name.value)\"),")
//        }
//        petsInEncounter.forEach { (pet) in
//            print("CollectibleItem(id: \(pet.id), name: \"\(pet.name.value)\"),")
//        }
        if mountsInEncounter.count > 0 || petsInEncounter.count > 0 {
            DispatchQueue.main.async {
                withAnimation {
                    mounts.append(contentsOf: mountsInEncounter)
                    pets.append(contentsOf: petsInEncounter)
                }
            }
        }
    }
}

//struct NotableItemsInRaid_Previews: PreviewProvider {
//    static var previews: some View {
//        NotableItemsInRaid()
//    }
//}
