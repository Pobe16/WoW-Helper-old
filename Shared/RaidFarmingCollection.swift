//
//  FarmingCollection.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 28/08/2020.
//

import SwiftUI

struct RaidFarmingCollection: View {
    let character: CharacterInProfile
    let data = (1...10).map { CGFloat($0) }

    let columns = [
        GridItem(.adaptive(minimum: 200), spacing: 20)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20, pinnedViews: [.sectionHeaders]) {
            
            Section(header: Text("Section 1").font(.title)) {
                ForEach(data, id: \.self) { _ in
                    Color(
                        UIColor(
                            red: CGFloat.random(in: 0...1),
                            green: CGFloat.random(in: 0...1),
                            blue: CGFloat.random(in: 0...1),
                            alpha: 1.0)
                    )
                    .frame(height: 200)
                    .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                }
            }
            
            Section(header: Text("Section 2").font(.title)) {
                ForEach(11...20, id: \.self) { _ in
                    Color(
                        UIColor(
                            red: CGFloat.random(in: 0...1),
                            green: CGFloat.random(in: 0...1),
                            blue: CGFloat.random(in: 0...1),
                            alpha: 1.0)
                    )
                    .frame(height: 200)
                    .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct RaidFarmingCollection_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ScrollView(){
                RaidFarmingCollection(character: placeholders.characterInProfile)
            }
            
            ScrollView(){
                RaidFarmingCollection(character: placeholders.characterInProfile)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            .previewDisplayName("iPhone 8")
        }
    }
}
