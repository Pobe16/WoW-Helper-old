//
//  LogOutListItem.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import SwiftUI

struct LogOutListItem: View {
    @EnvironmentObject var authorization: Authentication
    var body: some View {
        Button(action: {
            logOut()
        }, label: {
            HStack{
                Image("logout")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63, height: 63)
                    .cornerRadius(15, antialiased: true)
                Text("Log out!".uppercased())
                    .fontWeight(.bold)
            }
            .onTapGesture {
                logOut()
            }
        })
    }
    
    fileprivate func logOut() {
        authorization.oauth2.forgetTokens()
        authorization.loggedIn = false
        authorization.loggedBefore = false
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.UserLoggedBefore)
    }
}

struct LogOutListItem_Previews: PreviewProvider {
    static var previews: some View {
        LogOutListItem()
    }
}
