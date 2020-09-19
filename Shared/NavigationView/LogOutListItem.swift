//
//  LogOutListItem.swift
//  WoWWidget (iOS)
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
                Text("Log me out!")
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
        UserDefaults.standard.set(false, forKey: "UserLoggedBefore")
    }
}

struct LogOutListItem_Previews: PreviewProvider {
    static var previews: some View {
        LogOutListItem()
    }
}
