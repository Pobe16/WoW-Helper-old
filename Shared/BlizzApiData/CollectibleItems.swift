//
//  CollectibleItems.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 20/09/2020.
//

import Foundation

struct CollectibleItem: Hashable, Comparable, Equatable {
    static func == (lhs: CollectibleItem, rhs: CollectibleItem) -> Bool {
        lhs.itemID == rhs.itemID
    }
    
    static func < (lhs: CollectibleItem, rhs: CollectibleItem) -> Bool {
        lhs.itemID < rhs.itemID
    }
    
    let itemID: Int
    let name: String
    var icon: Data?
    let collectionID: Int
}

func createMountsList() -> [CollectibleItem] {
    let list = [
        // All repeatable loot from Vanilla - Battle For Azeroth
        CollectibleItem(itemID: 13335, name: "Deathcharger's Reins", collectionID: 69), /* Rivendare's Deathcharger */
        CollectibleItem(itemID: 35513, name: "Swift White Hawkstrider", collectionID: 213),
        CollectibleItem(itemID: 32768, name: "Reins of the Raven Lord", collectionID: 185),
        CollectibleItem(itemID: 44151, name: "Reins of the Blue Proto-Drake", collectionID: 264),
        CollectibleItem(itemID: 43951, name: "Reins of the Bronze Drake", collectionID: 248),
        CollectibleItem(itemID: 68824, name: "Swift Zulian Panther", collectionID: 411),
        CollectibleItem(itemID: 68823, name: "Armored Razzashi Raptor", collectionID: 410),
        CollectibleItem(itemID: 69747, name: "Amani Battle Bear", collectionID: 419),
        CollectibleItem(itemID: 30480, name: "Fiery Warhorse's Reins", collectionID: 168),
        CollectibleItem(itemID: 32458, name: "Ashes of Al'ar", collectionID: 183),
        CollectibleItem(itemID: 43959, name: "Reins of the Grand Black War Mammoth", collectionID: 286),
        CollectibleItem(itemID: 44083, name: "Reins of the Grand Black War Mammoth", collectionID: 287),
        CollectibleItem(itemID: 43952, name: "Reins of the Azure Drake", collectionID: 246),
        CollectibleItem(itemID: 43953, name: "Reins of the Blue Drake", collectionID: 247),
        CollectibleItem(itemID: 43986, name: "Reins of the Black Drake", collectionID: 253),
        CollectibleItem(itemID: 43954, name: "Reins of the Twilight Drake", collectionID: 250),
        CollectibleItem(itemID: 49636, name: "Reins of the Onyxian Drake", collectionID: 349),
        CollectibleItem(itemID: 45693, name: "Mimiron's Head", collectionID: 304),
        CollectibleItem(itemID: 50818, name: "Invincible's Reins", collectionID: 363),
        CollectibleItem(itemID: 63040, name: "Reins of the Drake of the North Wind", collectionID: 395),
        CollectibleItem(itemID: 63041, name: "Reins of the Drake of the South Wind", collectionID: 396),
        CollectibleItem(itemID: 63043, name: "Reins of the Vitreous Stone Drake", collectionID: 397),
        CollectibleItem(itemID: 71665, name: "Flametalon of Alysrazor", collectionID: 425),
        CollectibleItem(itemID: 69224, name: "Smoldering Egg of Millagazor", collectionID: 415), /* Pureblood Fire Hawk */
        CollectibleItem(itemID: 69230, name: "Corrupted Egg of Millagazor", collectionID: 417), /* Corrupted Fire Hawk */
        CollectibleItem(itemID: 78919, name: "Experiment 12-B", collectionID: 445),
        CollectibleItem(itemID: 77067, name: "Reins of the Blazing Drake", collectionID: 442),
        CollectibleItem(itemID: 77069, name: "Life-Binder's Handmaiden", collectionID: 444),
        CollectibleItem(itemID: 87771, name: "Reins of the Heavenly Onyx Cloud Serpent", collectionID: 473),
        CollectibleItem(itemID: 89783, name: "Son of Galleon's Saddle", collectionID: 515),
        CollectibleItem(itemID: 95057, name: "Reins of the Thundering Cobalt Cloud Serpent", collectionID: 542),
        CollectibleItem(itemID: 94228, name: "Reins of the Cobalt Primordial Direhorn", collectionID: 533),
        CollectibleItem(itemID: 87777, name: "Reins of the Astral Cloud Serpent", collectionID: 478),
        CollectibleItem(itemID: 93666, name: "Spawn of Horridon", collectionID: 531),
        CollectibleItem(itemID: 95059, name: "Clutch of Ji-Kun", collectionID: 543),
        CollectibleItem(itemID: 104253, name: "Kor'kron Juggernaut", collectionID: 559),
        CollectibleItem(itemID: 116771, name: "Solar Spirehawk", collectionID: 634),
        CollectibleItem(itemID: 116660, name: "Ironhoof Destroyer", collectionID: 613),
        CollectibleItem(itemID: 123890, name: "Felsteel Annihilator", collectionID: 751),
        CollectibleItem(itemID: 142236, name: "Midnight's Eternal Reins", collectionID: 875),
        CollectibleItem(itemID: 142552, name: "Smoldering Ember Wyrm", collectionID: 883),
        CollectibleItem(itemID: 137574, name: "Living Infernal Core", collectionID: 791), /* Felblaze Infernal */
        CollectibleItem(itemID: 137575, name: "Fiendish Hellfire Core", collectionID: 633), /* Hellfire Infernal */
        CollectibleItem(itemID: 143643, name: "Abyss Worm", collectionID: 899),
        CollectibleItem(itemID: 152816, name: "Antoran Charhound", collectionID: 971),
        CollectibleItem(itemID: 152789, name: "Shackled Ur'zul", collectionID: 954),
        CollectibleItem(itemID: 159842, name: "Sharkbait's Favorite Crackers", collectionID: 995),
        CollectibleItem(itemID: 160829, name: "Underrot Crawg Harness", collectionID: 1053),
        CollectibleItem(itemID: 159921, name: "Mummified Raptor Skull", collectionID: 1040), /* Tomb Stalker */
        CollectibleItem(itemID: 166518, name: "G.M.O.D.", collectionID: 1217),
        CollectibleItem(itemID: 166705, name: "Glacial Tidestorm", collectionID: 1219),
        CollectibleItem(itemID: 174872, name: "Ny'alotha Allseer", collectionID: 1293),
        // End of Vanilla To Battle For Azeroth
        
    ]
    return list
}

func createPetsList() -> [CollectibleItem] {
    let list = [
        // MARK: Start of Raids Vanilla - Battle For Azeroth
        CollectibleItem(itemID: 127749, name: "Corrupted Nest Guardian", collectionID: 1672),
        CollectibleItem(itemID: 104162, name: "Droplet of Y'Shaarj", collectionID: 1331),
        CollectibleItem(itemID: 104163, name: "Gooey Sha-ling", collectionID: 1332),
        CollectibleItem(itemID: 104158, name: "Blackfuse Bombling", collectionID: 1322),
        CollectibleItem(itemID: 94574, name: "Pygmy Direhorn", collectionID: 1200),
        CollectibleItem(itemID: 94835, name: "Ji-Kun Hatchling", collectionID: 1202),
        CollectibleItem(itemID: 97959, name: "Quivering Blob", collectionID: 1243), /* Living Fluid */
        CollectibleItem(itemID: 97960, name: "Dark Quivering Blob", collectionID: 1244), /* Viscous Horror */
        CollectibleItem(itemID: 94152, name: "Son of Animus", collectionID: 1183),
        CollectibleItem(itemID: 167055, name: "Amber Goo Puddle", collectionID: 2589), /* Living Amber */
        CollectibleItem(itemID: 167054, name: "Spawn of Garalon", collectionID: 2587),
        CollectibleItem(itemID: 167058, name: "Kor'thik Swarmling", collectionID: 2585),
        CollectibleItem(itemID: 167056, name: "Essence of Pride", collectionID: 2590), /* Ravenous Prideling */
        CollectibleItem(itemID: 167053, name: "Tiny Amber Wings", collectionID: 2586), /* Amberglow Stinger */
        CollectibleItem(itemID: 167051, name: "Azure Cloud Serpent Egg", collectionID: 2583), /* Azure Windseeker */
        CollectibleItem(itemID: 167052, name: "Spirit of the Spring", collectionID: 2584),
        CollectibleItem(itemID: 167049, name: "Celestial Gift", collectionID: 2581), /* Comet */
        CollectibleItem(itemID: 167050, name: "Mogu Statue", collectionID: 2582), /* Baoh-Xi */
        CollectibleItem(itemID: 167047, name: "Stoneclaw", collectionID: 2579),
        CollectibleItem(itemID: 167048, name: "Wayward Spirit", collectionID: 2580),
        CollectibleItem(itemID: 152979, name: "Puddle of Black Liquid", collectionID: 2090), /* Faceless Mindlasher */
        CollectibleItem(itemID: 152980, name: "Elementium Back Plate", collectionID: 2091), /* Corrupted Blood */
        CollectibleItem(itemID: 152981, name: "Severed Tentacle", collectionID: 2092), /* Unstable Tendril*/
        CollectibleItem(itemID: 152978, name: "Fandral's Pet Carrier", collectionID: 2089), /* Infernal Pyreclaw */
        CollectibleItem(itemID: 152975, name: "Smoldering Treat", collectionID: 2086), /* Blazehound */
        CollectibleItem(itemID: 152977, name: "Vibrating Stone", collectionID: 2088), /* Surger */
        CollectibleItem(itemID: 152976, name: "Cinderweb Egg", collectionID: 2087), /* Cinderweb Recluse */
        CollectibleItem(itemID: 152973, name: "Zephyr's Call", collectionID: 2084), /* Zephyrian Prince */
        CollectibleItem(itemID: 152974, name: "Breezy Essence", collectionID: 2085), /* Drafty */
        CollectibleItem(itemID: 152968, name: "Shadowy Pile of Bones", collectionID: 2080), /* Rattlejaw*/
        CollectibleItem(itemID: 152966, name: "Rough-Hewn Remote", collectionID: 2078), /* Tinytron */
        CollectibleItem(itemID: 152967, name: "Experiment-In-A-Jar", collectionID: 2079), /* Discarded Experiment */
        CollectibleItem(itemID: 152969, name: "Odd Twilight Egg", collectionID: 2081), /* Twilight Clutch-Sister */
        CollectibleItem(itemID: 152972, name: "Twilight Summoning Portal", collectionID: 2083), /* Faceless Minion */
        CollectibleItem(itemID: 152970, name: "Lesser Circle of Binding", collectionID: 2082), /* Bound Stream */
        CollectibleItem(itemID: 142091, name: "Blessed Seed", collectionID: 1960), /* Snaplasher */
        CollectibleItem(itemID: 142086, name: "Red-Hot Coal", collectionID: 1955), /* Magma Rageling */
        CollectibleItem(itemID: 142093, name: "Wriggling Darkness", collectionID: 1962), /* Creeping Tentacle */
        CollectibleItem(itemID: 142092, name: "Overcomplicated Controller", collectionID: 1961), /* G0-R41-0N Ultratonk */
        CollectibleItem(itemID: 142090, name: "Ominous Pile of Snow", collectionID: 1959), /* Winter Rageling */
        CollectibleItem(itemID: 142087, name: "Ironbound Collar", collectionID: 1956), /* Ironbound Proto-Whelp */
        CollectibleItem(itemID: 142088, name: "Stormforged Rune", collectionID: 1957), /* Runeforged Servitor */
        CollectibleItem(itemID: 142089, name: "Glittering Ball of Yarn", collectionID: 1958), /* Sanctum Cub */
        CollectibleItem(itemID: 142094, name: "Fragment of Frozen Bone", collectionID: 1963), /* Boneshard */
        CollectibleItem(itemID: 142095, name: "Remains of a Blood Beast", collectionID: 1964), /* Blood Boil*/
        CollectibleItem(itemID: 142096, name: "Putricide's Alchemy Supplies", collectionID: 1965), /* Blightbreath */
        CollectibleItem(itemID: 142097, name: "Skull of a Frozen Whelp", collectionID: 1966), /* Soulbroken Whelpling */
        CollectibleItem(itemID: 142098, name: "Drudge Remains", collectionID: 1967), /* Drudge Ghoul */
        CollectibleItem(itemID: 142099, name: "Call of the Frozen Blade", collectionID: 1968), /* Wicked Soul */
        CollectibleItem(itemID: 142083, name: "Giant Worm Egg", collectionID: 1952), /* Dreadmaw */
        CollectibleItem(itemID: 142084, name: "Magnataur Hunting Horn", collectionID: 1953), /* Snobold Runt */
        CollectibleItem(itemID: 142085, name: "Nerubian Relic", collectionID: 1954), /* Nerubian Swarmer */
        CollectibleItem(itemID: 93030, name: "Dusty Clutch of Eggs", collectionID: 1143), /* Giant Bone Spider */
        CollectibleItem(itemID: 93032, name: "Blighted Spore", collectionID: 1144), /* Fungal Abomination */
        CollectibleItem(itemID: 93029, name: "Gluth's Bone", collectionID: 1146), /* Stitched Pup */
        CollectibleItem(itemID: 122115, name: "Servant's Bell", collectionID: 1634), /* Wretched Servant */
        CollectibleItem(itemID: 122113, name: "Sunblade Rune of Activation", collectionID: 1632), /* Sunblade Micro-Defender */
        CollectibleItem(itemID: 122114, name: "Void Collar", collectionID: 1633), /* Chaos Pup */
        CollectibleItem(itemID: 122106, name: "Shard of Supremus", collectionID: 1624), /* Abyssius */
        CollectibleItem(itemID: 122104, name: "Leviathan Egg", collectionID: 1623), /* Leviathan Hatchling */
        CollectibleItem(itemID: 122110, name: "Sultry Grimoire", collectionID: 1628), /* Sister of Temptation */
        CollectibleItem(itemID: 122107, name: "Fragment of Anger", collectionID: 1625),
        CollectibleItem(itemID: 122109, name: "Fragment of Desire", collectionID: 1627),
        CollectibleItem(itemID: 122108, name: "Fragment of Suffering", collectionID: 1626),
        CollectibleItem(itemID: 122111, name: "Smelly Gravestone", collectionID: 1629), /* Stinkrot */
        CollectibleItem(itemID: 122105, name: "Grotesque Statue", collectionID: 1622), /* Grotesque */
        CollectibleItem(itemID: 122112, name: "Hyjal Wisp", collectionID: 1631),
        CollectibleItem(itemID: 97555, name: "Tiny Fel Engine Key", collectionID: 1233), /* Pocket Reaver */
        CollectibleItem(itemID: 97557, name: "Brilliant Phoenix Hawk Feather", collectionID: 1235), /* Phoenix Hawk Hatchling */
        CollectibleItem(itemID: 97556, name: "Crystal of the Void", collectionID: 1234), /* Lesser Voidcaller */
        CollectibleItem(itemID: 97554, name: "Dripping Strider Egg", collectionID: 1232), /* Coilfang Stalker */
        CollectibleItem(itemID: 97552, name: "Shell of Tide-Calling", collectionID: 1230), /* Tideskipper */
        CollectibleItem(itemID: 97553, name: "Tainted Core", collectionID: 1231), /* Tainted Waveling */
        CollectibleItem(itemID: 97551, name: "Satyr Charm", collectionID: 1229), /* Fiendish Imp */
        CollectibleItem(itemID: 97548, name: "Spiky Collar", collectionID: 1226), /* Lil' Bad Wolf */
        CollectibleItem(itemID: 97550, name: "Netherspace Portal-Stone", collectionID: 1228), /* Netherspace Abyssal*/
        CollectibleItem(itemID: 97549, name: "Instant Arcane Sanctum Security Kit", collectionID: 1227), /* Menagerie Custodian */
        CollectibleItem(itemID: 93041, name: "Jewel of Maddening Whispers", collectionID: 1156), /* Mini Mindslayer */
        CollectibleItem(itemID: 93039, name: "Viscidus Globule", collectionID: 1154),
        CollectibleItem(itemID: 93040, name: "Anubisath Idol", collectionID: 1155),
        CollectibleItem(itemID: 93037, name: "Blackwing Banner", collectionID: 1153), /* Death Talon Whelpguard */
        CollectibleItem(itemID: 93038, name: "Whistle of Chromatic Bone", collectionID: 1152), /* Chrominius */
        CollectibleItem(itemID: 93036, name: "Unscathed Egg", collectionID: 1151), /* Untamed Hatchling */
        CollectibleItem(itemID: 93033, name: "Mark of Flame", collectionID: 1147), /* Harbinger of Flame */
        CollectibleItem(itemID: 93034, name: "Blazing Rune", collectionID: 1149), /* Corefire Imp */
        CollectibleItem(itemID: 93035, name: "Core of Hardened Ash", collectionID: 1150), /* Ashstone Core */
        // MARK: End of Raids Vanilla - Battle For Azeroth
    ]
    return list
}
