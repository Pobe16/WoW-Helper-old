//
//  NoFarmingLeft.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 07/10/2020.
//

import SwiftUI

struct NoFarmingLeft: View {
    @Namespace private var noFarmingLeft
    
    let summarySize: summaryPreviewSize
    
    let character: CharacterInProfile
    
    var body: some View {
        
        switch summarySize {
        case .large:
            VStack{
                HStack(alignment: .top) {
                    CharacterImage(character: character)
                        .padding()
                        .matchedGeometryEffect(id: "characterImage", in: noFarmingLeft)
                    Spacer(minLength: 0)
                    Text("\(character.name), \(character.level)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.5)
                        .matchedGeometryEffect(id: "characterName", in: noFarmingLeft)
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text("All done!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .minimumScaleFactor(0.9)
                        .matchedGeometryEffect(id: "allDone", in: noFarmingLeft)
                    Spacer(minLength: 0)
                }
                .padding()
            }
            .frame(width: 292, height: 311)
            .background(
                Image("Goldshire_Inn")
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(id: "background", in: noFarmingLeft)
            )
            .cornerRadius(15)
            
        case .medium:
            VStack{
                HStack(alignment: .top) {
                    CharacterImage(character: character)
                        .padding()
                        .matchedGeometryEffect(id: "characterImage", in: noFarmingLeft)
                    Spacer(minLength: 0)
                    Text("\(character.name), \(character.level)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.9)
                        .matchedGeometryEffect(id: "characterName", in: noFarmingLeft)
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text("All done!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .minimumScaleFactor(0.9)
                        .matchedGeometryEffect(id: "allDone", in: noFarmingLeft)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: 292, height: 141)
            .background(
                Image("Goldshire_Inn")
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(id: "background", in: noFarmingLeft)
            )
            .cornerRadius(15)
            
        case .small:
            VStack{
                HStack {
                    CharacterImage(character: character, frameSize: 50)
                        .padding()
                        .matchedGeometryEffect(id: "characterImage", in: noFarmingLeft)
                    Spacer()
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text("All done!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .whiteTextWithBlackOutlineStyle()
                        .padding()
                        .minimumScaleFactor(0.5)
                        .matchedGeometryEffect(id: "allDone", in: noFarmingLeft)
                    Spacer(minLength: 0)
                }
            }
            .frame(width: 141, height: 141)
            .background(
                Image("Goldshire_Inn_Mini")
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(id: "background", in: noFarmingLeft)
            )
            .cornerRadius(15)
        }
    }
}

struct NoFarmingLeft_Previews: PreviewProvider {
    static var previews: some View {
        NoFarmingLeft(summarySize: .large, character: placeholders.characterInProfile)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 850, height: 350))
            .environmentObject(Authentication())
        
        NoFarmingLeft(summarySize: .large, character: placeholders.characterInProfile)
            .previewLayout(.fixed(width: 850, height: 350))
            .environmentObject(Authentication())
    }
}
