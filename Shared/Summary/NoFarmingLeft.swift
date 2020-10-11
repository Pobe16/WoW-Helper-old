//
//  NoFarmingLeft.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 07/10/2020.
//

import SwiftUI

struct NoFarmingLeft: View {
    
    let character: CharacterInProfile
    
    var body: some View {
        ScrollView(.horizontal) {
            
            HStack(alignment: .top, spacing: 20) {
                
                VStack{
                    HStack(alignment: .top) {
                        CharacterImage(character: character)
                            .padding()
                        Spacer(minLength: 0)
                        Text("\(character.name), \(character.level)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .whiteTextWithBlackOutlineStyle()
                            .padding()
                            .minimumScaleFactor(0.5)
                    }
                    Spacer(minLength: 0)
                    HStack {
                        Spacer(minLength: 0)
                        Text("All done!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .whiteTextWithBlackOutlineStyle()
                            .minimumScaleFactor(0.9)
                        Spacer(minLength: 0)
                    }
                    .padding()
                }
                .frame(width: 292, height: 311)
                .background(
                    Image("Goldshire_Inn")
                        .resizable()
                        .scaledToFill()
                )
                .cornerRadius(15)
                               
                VStack{
                    HStack(alignment: .top) {
                        CharacterImage(character: character)
                            .padding()
                        Spacer(minLength: 0)
                        Text("\(character.name), \(character.level)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .whiteTextWithBlackOutlineStyle()
                            .padding()
                            .minimumScaleFactor(0.9)
//                        Spacer()
                    }
                    Spacer(minLength: 0)
                    HStack {
                        Spacer(minLength: 0)
                        Text("All done!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .whiteTextWithBlackOutlineStyle()
                            .minimumScaleFactor(0.9)
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
                )
                .cornerRadius(15)
                
                VStack{
                    HStack {
                        CharacterImage(character: character, frameSize: 50)
                            .padding()
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
                        Spacer(minLength: 0)
                    }
                }
                .frame(width: 141, height: 141)
                .background(
                    Image("Goldshire_Inn_Mini")
                        .resizable()
                        .scaledToFill()
                )
                .cornerRadius(15)
            }
            .padding()
        }
    }
}

struct NoFarmingLeft_Previews: PreviewProvider {
    static var previews: some View {
        NoFarmingLeft(character: placeholders.characterInProfile)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 850, height: 350))
            .environmentObject(Authentication())
        
        NoFarmingLeft(character: placeholders.characterInProfile)
            .previewLayout(.fixed(width: 850, height: 350))
            .environmentObject(Authentication())
    }
}
