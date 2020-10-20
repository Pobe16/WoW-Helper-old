//
//  Credits.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 18/10/2020.
//

import SwiftUI

struct Credits: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    let greetings = [
        "Citizens of Dalaran!",
        "Watch yer back!",
        "Interest you in a pint?",
        "An illusion! What are you hiding?",
        "You think you want it, but you don't.",
        "Stay away from the voodoo",
        "Lok'Tar ogar!",
        "Garrosh did nothing wrong…"
    ]
    
    var body: some View {
        ScrollView(Axis.Set.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                HStack{
                    Spacer()
                    Text(greetings.randomElement()!)
                        .font(.largeTitle)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal)
                Text("This app has been developed during summer / autumn of 2020 in Scotland, in the long wait for Shadowlands, and with a one year old boy desperately trying to press the nice red button on the power supply for my computer. A big thank you to my wife for giving me time to pursue my passions.")
                    .font(.title)
                    .padding(.all)
                Text("Development (SwiftUI):\nMikołaj \"Pobe\" Łukasik")
                    .font(.title2)
                    .padding([.horizontal,.top])
                Link("@Pobe",
                      destination: URL(string: "https://twitter.com/Pobe")!)
                    .font(.title2)
                    .padding([.horizontal,.bottom])
                Text("Consultation (UI help):\nSakuya")
                        .font(.title2)
                        .padding(.all)
                Text("Textures:\nThe Forgotten Adventures")
                    .font(.title2)
                    .padding([.horizontal,.top])
                Link("The Forgotten Adventures",
                      destination: URL(string: "https://www.forgotten-adventures.net/")!)
                    .font(.title2)
                    .padding([.horizontal,.bottom])
                Text("Using World of Warcraft API from Blizzard")
                        .font(.title2)
                        .padding(.all)
                Spacer()
            }
            .padding(.horizontal)
        }
        .background(
            BackgroundTexture(texture: .ice, wall: .horizontal)
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Credits")
            }
        }
    }
}

struct Credits_Previews: PreviewProvider {
    static var previews: some View {
        Credits().previewDevice(.init(rawValue: "iPhone 12 Pro Max"))
    }
}
