//
//  InstancePlaceholderTile.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct InstancePlaceholderTile: View {
    @Environment(\.colorScheme) var colorScheme
    let category: String
    
    var body: some View {
        
        ZStack{
            Image("\(category)_placeholder")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 150)
                .cornerRadius(15, antialiased: true)
            
            VStack(alignment: .leading){
                Spacer()
                Spacer()
                HStack{
                    Spacer()
                    Text("Bosses: 0")
                        .padding(.vertical, 4)
                    Spacer()
                    
                }
                .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.8))
                Spacer()
                HStack{
                    Spacer()
                    Text("Loading…")
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.vertical, 4)
                    Spacer()
                }
                .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.8))
                    
                
            }
            .frame(width: 200, height: 150)
        }
        .cornerRadius(15, antialiased: true)
        
    }
}

struct InstancePlaceholderTile_Previews: PreviewProvider {
    static var previews: some View {
        InstancePlaceholderTile(category: "dungeon")
    }
}
