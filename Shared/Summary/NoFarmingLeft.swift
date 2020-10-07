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
            
            HStack(spacing: 10){
                Spacer()
                VStack{
                    HStack {
                        CharacterImage(character: character, frameSize: 50)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: 141, height: 141)
                .background(
                    Image("Goldshire_Inn")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                )
                .cornerRadius(15)
                
                VStack{
                    HStack {
                        CharacterImage(character: character)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }.frame(width: 292, height: 141)
                .background(
                    Image("Goldshire_Inn")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 292, height: 141)
                        .clipped()
                )
                .cornerRadius(15)
                
                VStack{
                    HStack {
                        CharacterImage(character: character)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: 292, height: 311)
                .background(
                    Image("Goldshire_Inn")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 292, height: 311)
                        .clipped()
                )
                .cornerRadius(15)
                Spacer()
            }
            
        }
    }
}

struct NoFarmingLeft_Previews: PreviewProvider {
    static var previews: some View {
        NoFarmingLeft(character: placeholders.characterInProfile)
            .previewLayout(.fixed(width: 850, height: 350))
    }
}
