//
//  LogOutListItem.swift
//  WoWWidget (iOS)
//
//  Created by Mikolaj Lukasik on 19/08/2020.
//

import SwiftUI

struct LogOutListItem: View {
    @Binding var loggedIn: Bool
    @EnvironmentObject var authorization: Authentication
    var body: some View {
        Button(action: {
            self.logOut()
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
                self.logOut()
            }
        })
    }
    
    fileprivate func logOut() {
        authorization.oauth2?.forgetTokens()
        loggedIn = false
    }
}

struct LogOutListItem_Previews: PreviewProvider {
    static var previews: some View {
        LogOutListItem(loggedIn: .constant(true))
    }
}
