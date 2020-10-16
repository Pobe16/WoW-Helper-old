//
//  CollectibleItems.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 20/09/2020.
//

import Foundation

struct CollectibleItem: Hashable, Comparable, Equatable {
    static func == (lhs: CollectibleItem, rhs: CollectibleItem) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: CollectibleItem, rhs: CollectibleItem) -> Bool {
        lhs.id < rhs.id
    }
    
    let id: Int
    let name: String
    var icon: Data?
}

func createMountsList() -> [CollectibleItem] {
    let list = [
        CollectibleItem(id: 13335, name: "Deathcharger's Reins"),
        CollectibleItem(id: 35513, name: "Swift White Hawkstrider"),
        CollectibleItem(id: 32768, name: "Reins of the Raven Lord"),
        CollectibleItem(id: 44151, name: "Reins of the Blue Proto-Drake"),
        CollectibleItem(id: 43951, name: "Reins of the Bronze Drake"),
        CollectibleItem(id: 68824, name: "Swift Zulian Panther"),
        CollectibleItem(id: 68823, name: "Armored Razzashi Raptor"),
        CollectibleItem(id: 69747, name: "Amani Battle Bear"),
        CollectibleItem(id: 30480, name: "Fiery Warhorse's Reins"),
        CollectibleItem(id: 32458, name: "Ashes of Al'ar"),
        CollectibleItem(id: 43959, name: "Reins of the Grand Black War Mammoth"),
        CollectibleItem(id: 44083, name: "Reins of the Grand Black War Mammoth"),
        CollectibleItem(id: 43952, name: "Reins of the Azure Drake"),
        CollectibleItem(id: 43953, name: "Reins of the Blue Drake"),
        CollectibleItem(id: 43986, name: "Reins of the Black Drake"),
        CollectibleItem(id: 43954, name: "Reins of the Twilight Drake"),
        CollectibleItem(id: 49636, name: "Reins of the Onyxian Drake"),
        CollectibleItem(id: 45693, name: "Mimiron's Head"),
        CollectibleItem(id: 50818, name: "Invincible's Reins"),
        CollectibleItem(id: 63040, name: "Reins of the Drake of the North Wind"),
        CollectibleItem(id: 63041, name: "Reins of the Drake of the South Wind"),
        CollectibleItem(id: 63043, name: "Reins of the Vitreous Stone Drake"),
        CollectibleItem(id: 71665, name: "Flametalon of Alysrazor"),
        CollectibleItem(id: 69224, name: "Smoldering Egg of Millagazor"),
        CollectibleItem(id: 69230, name: "Corrupted Egg of Millagazor"),
        CollectibleItem(id: 78919, name: "Experiment 12-B"),
        CollectibleItem(id: 77067, name: "Reins of the Blazing Drake"),
        CollectibleItem(id: 77069, name: "Life-Binder's Handmaiden"),
        CollectibleItem(id: 87771, name: "Reins of the Heavenly Onyx Cloud Serpent"),
        CollectibleItem(id: 89783, name: "Son of Galleon's Saddle"),
        CollectibleItem(id: 95057, name: "Reins of the Thundering Cobalt Cloud Serpent"),
        CollectibleItem(id: 94228, name: "Reins of the Cobalt Primordial Direhorn"),
        CollectibleItem(id: 87777, name: "Reins of the Astral Cloud Serpent"),
        CollectibleItem(id: 93666, name: "Spawn of Horridon"),
        CollectibleItem(id: 95059, name: "Clutch of Ji-Kun"),
        CollectibleItem(id: 104253, name: "Kor'kron Juggernaut"),
        CollectibleItem(id: 116771, name: "Solar Spirehawk"),
        CollectibleItem(id: 116660, name: "Ironhoof Destroyer"),
        CollectibleItem(id: 123890, name: "Felsteel Annihilator"),
        CollectibleItem(id: 142236, name: "Midnight's Eternal Reins"),
        CollectibleItem(id: 142552, name: "Smoldering Ember Wyrm"),
        CollectibleItem(id: 137574, name: "Living Infernal Core"),
        CollectibleItem(id: 137575, name: "Fiendish Hellfire Core"),
        CollectibleItem(id: 143643, name: "Abyss Worm"),
        CollectibleItem(id: 152816, name: "Antoran Charhound"),
        CollectibleItem(id: 152789, name: "Shackled Ur'zul"),
        CollectibleItem(id: 159842, name: "Sharkbait's Favorite Crackers"),
        CollectibleItem(id: 160829, name: "Underrot Crawg Harness"),
        CollectibleItem(id: 159921, name: "Mummified Raptor Skull"),
        CollectibleItem(id: 166518, name: "G.M.O.D."),
        CollectibleItem(id: 166705, name: "Glacial Tidestorm"),
        CollectibleItem(id: 174872, name: "Ny'alotha Allseer"),
    ]
    return list
}

func createPetsList() -> [CollectibleItem] {
    let list = [
        // MARK: Start of Raids Vanilla - Battle For Azeroth
        CollectibleItem(id: 127749, name: "Corrupted Nest Guardian"),
        CollectibleItem(id: 104162, name: "Droplet of Y'Shaarj"),
        CollectibleItem(id: 104163, name: "Gooey Sha-ling"),
        CollectibleItem(id: 104158, name: "Blackfuse Bombling"),
        CollectibleItem(id: 104162, name: "Droplet of Y'Shaarj"),
        CollectibleItem(id: 94574, name: "Pygmy Direhorn"),
        CollectibleItem(id: 94835, name: "Ji-Kun Hatchling"),
        CollectibleItem(id: 97959, name: "Quivering Blob"),
        CollectibleItem(id: 97960, name: "Dark Quivering Blob"),
        CollectibleItem(id: 94152, name: "Son of Animus"),
        CollectibleItem(id: 167055, name: "Amber Goo Puddle"),
        CollectibleItem(id: 167054, name: "Spawn of Garalon"),
        CollectibleItem(id: 167058, name: "Kor'thik Swarmling"),
        CollectibleItem(id: 167056, name: "Essence of Pride"),
        CollectibleItem(id: 167053, name: "Tiny Amber Wings"),
        CollectibleItem(id: 167056, name: "Essence of Pride"),
        CollectibleItem(id: 167051, name: "Azure Cloud Serpent Egg"),
        CollectibleItem(id: 167052, name: "Spirit of the Spring"),
        CollectibleItem(id: 167049, name: "Celestial Gift"),
        CollectibleItem(id: 167050, name: "Mogu Statue"),
        CollectibleItem(id: 167047, name: "Stoneclaw"),
        CollectibleItem(id: 167048, name: "Wayward Spirit"),
        CollectibleItem(id: 167050, name: "Mogu Statue"),
        CollectibleItem(id: 152979, name: "Puddle of Black Liquid"),
        CollectibleItem(id: 152980, name: "Elementium Back Plate"),
        CollectibleItem(id: 152981, name: "Severed Tentacle"),
        CollectibleItem(id: 152978, name: "Fandral's Pet Carrier"),
        CollectibleItem(id: 152975, name: "Smoldering Treat"),
        CollectibleItem(id: 152977, name: "Vibrating Stone"),
        CollectibleItem(id: 152976, name: "Cinderweb Egg"),
        CollectibleItem(id: 152973, name: "Zephyr's Call"),
        CollectibleItem(id: 152974, name: "Breezy Essence"),
        CollectibleItem(id: 152968, name: "Shadowy Pile of Bones"),
        CollectibleItem(id: 152966, name: "Rough-Hewn Remote"),
        CollectibleItem(id: 152967, name: "Experiment-In-A-Jar"),
        CollectibleItem(id: 152968, name: "Shadowy Pile of Bones"),
        CollectibleItem(id: 152969, name: "Odd Twilight Egg"),
        CollectibleItem(id: 152972, name: "Twilight Summoning Portal"),
        CollectibleItem(id: 152970, name: "Lesser Circle of Binding"),
        CollectibleItem(id: 142091, name: "Blessed Seed"),
        CollectibleItem(id: 142086, name: "Red-Hot Coal"),
        CollectibleItem(id: 142093, name: "Wriggling Darkness"),
        CollectibleItem(id: 142092, name: "Overcomplicated Controller"),
        CollectibleItem(id: 142090, name: "Ominous Pile of Snow"),
        CollectibleItem(id: 142087, name: "Ironbound Collar"),
        CollectibleItem(id: 142088, name: "Stormforged Rune"),
        CollectibleItem(id: 142089, name: "Glittering Ball of Yarn"),
        CollectibleItem(id: 142094, name: "Fragment of Frozen Bone"),
        CollectibleItem(id: 142095, name: "Remains of a Blood Beast"),
        CollectibleItem(id: 142096, name: "Putricide's Alchemy Supplies"),
        CollectibleItem(id: 142097, name: "Skull of a Frozen Whelp"),
        CollectibleItem(id: 142098, name: "Drudge Remains"),
        CollectibleItem(id: 142099, name: "Call of the Frozen Blade"),
        CollectibleItem(id: 142083, name: "Giant Worm Egg"),
        CollectibleItem(id: 142084, name: "Magnataur Hunting Horn"),
        CollectibleItem(id: 142085, name: "Nerubian Relic"),
        CollectibleItem(id: 93030, name: "Dusty Clutch of Eggs"),
        CollectibleItem(id: 93032, name: "Blighted Spore"),
        CollectibleItem(id: 93029, name: "Gluth's Bone"),
        CollectibleItem(id: 122115, name: "Servant's Bell"),
        CollectibleItem(id: 122113, name: "Sunblade Rune of Activation"),
        CollectibleItem(id: 122114, name: "Void Collar"),
        CollectibleItem(id: 122106, name: "Shard of Supremus"),
        CollectibleItem(id: 122104, name: "Leviathan Egg"),
        CollectibleItem(id: 122110, name: "Sultry Grimoire"),
        CollectibleItem(id: 122107, name: "Fragment of Anger"),
        CollectibleItem(id: 122109, name: "Fragment of Desire"),
        CollectibleItem(id: 122108, name: "Fragment of Suffering"),
        CollectibleItem(id: 122111, name: "Smelly Gravestone"),
        CollectibleItem(id: 122105, name: "Grotesque Statue"),
        CollectibleItem(id: 122112, name: "Hyjal Wisp"),
        CollectibleItem(id: 97555, name: "Tiny Fel Engine Key"),
        CollectibleItem(id: 97557, name: "Brilliant Phoenix Hawk Feather"),
        CollectibleItem(id: 97556, name: "Crystal of the Void"),
        CollectibleItem(id: 97554, name: "Dripping Strider Egg"),
        CollectibleItem(id: 97552, name: "Shell of Tide-Calling"),
        CollectibleItem(id: 97553, name: "Tainted Core"),
        CollectibleItem(id: 97551, name: "Satyr Charm"),
        CollectibleItem(id: 97548, name: "Spiky Collar"),
        CollectibleItem(id: 97550, name: "Netherspace Portal-Stone"),
        CollectibleItem(id: 97549, name: "Instant Arcane Sanctum Security Kit"),
        CollectibleItem(id: 97550, name: "Netherspace Portal-Stone"),
        CollectibleItem(id: 93041, name: "Jewel of Maddening Whispers"),
        CollectibleItem(id: 93039, name: "Viscidus Globule"),
        CollectibleItem(id: 93040, name: "Anubisath Idol"),
        CollectibleItem(id: 93037, name: "Blackwing Banner"),
        CollectibleItem(id: 93038, name: "Whistle of Chromatic Bone"),
        CollectibleItem(id: 93036, name: "Unscathed Egg"),
        CollectibleItem(id: 93033, name: "Mark of Flame"),
        CollectibleItem(id: 93034, name: "Blazing Rune"),
        CollectibleItem(id: 93035, name: "Core of Hardened Ash")
        // MARK: End of Raids Vanilla - Battle For Azeroth
    ]
    return list
}
