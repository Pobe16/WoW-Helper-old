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
        GridItem(.adaptive(minimum: 180), spacing: 30)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 30, pinnedViews: [.sectionHeaders]) {
                
                Section(header:
                            HStack{
                                Spacer()
                                Text("Section 1")
                                    .font(.title)
                                Spacer()
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 0)
                            .background(Color.gray.opacity(0.7))
                ) {
                    ForEach(data, id: \.self) { _ in
                        Color(
                            UIColor(
                                red: CGFloat.random(in: 0...1),
                                green: CGFloat.random(in: 0...1),
                                blue: CGFloat.random(in: 0...1),
                                alpha: 1.0)
                        )
                        .frame(height: 180)
                        .cornerRadius(30)
                    }
                }
            }
            .padding()
        }
    }
}

#if DEBUG
struct RaidFarmingCollection_Previews: PreviewProvider {
    static var previews: some View {
        RaidFarmingCollection(character: placeholders.characterInProfile)
        
        RaidFarmingCollection(character: placeholders.characterInProfile)
        .previewLayout(.fixed(width: 320, height: 568))
        .previewDisplayName("iPhone SE 1st gen")
                    
        RaidFarmingCollection(character: placeholders.characterInProfile)
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
        .previewDisplayName("iPhone 8")
    }
}
#endif
