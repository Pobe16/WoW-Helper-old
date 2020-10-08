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
                    HStack {
                        CharacterImage(character: character)
                            .padding()
                        Spacer(minLength: 0)
                        Text("\(character.name), \(character.level)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .minimumScaleFactor(0.5)
                            .background(
                                InstanceProgressFullWidthBackgroundBlur(blurOpacity: 0.7)
                            )
                            .cornerRadius(15)
                            .padding()
//                        Spacer()
                    }
                    Spacer(minLength: 0)
                    HStack {
                        Spacer(minLength: 0)
                        Text("All done!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.9)
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .background(
                        InstanceProgressFullWidthBackgroundBlur(blurOpacity: 0.7)
                    )
                }
                .frame(width: 292, height: 311)
                .background(
                    Image("Goldshire_Inn")
                        .resizable()
                        .scaledToFill()
                )
                .cornerRadius(15)
                               
                VStack{
                    HStack {
                        CharacterImage(character: character)
                            .padding()
                        Spacer(minLength: 0)
                        Text("\(character.name), \(character.level)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .minimumScaleFactor(0.9)
                            .background(
                                InstanceProgressFullWidthBackgroundBlur(blurOpacity: 0.7)
                            )
                            .cornerRadius(15)
                            .padding()
//                        Spacer()
                    }
                    Spacer(minLength: 0)
                    HStack {
                        Spacer(minLength: 0)
                        Text("All done!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.9)
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .background(
                        InstanceProgressFullWidthBackgroundBlur(blurOpacity: 0.7)
                    )
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
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .minimumScaleFactor(0.5)
                        Spacer(minLength: 0)
                    }
                    .background(
                        InstanceProgressFullWidthBackgroundBlur(blurOpacity: 0.7)
                    )
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
            .previewLayout(.fixed(width: 850, height: 350))
            .environmentObject(Authentication())
    }
}
