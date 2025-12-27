//
//  SearchProfileButton.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import SwiftUI
import Kingfisher
struct SearchProfileButton: View {
    let user:UserSummary
    var onTap: () -> Void
    var body: some View {
        Button{
            onTap()
        }label: {
            HStack {
               
                KFImage(user.avatarURL)
                    .placeholder {
                                    ProgressView()
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(content: {
                                    Circle()
                                        .stroke(Color.secondary, lineWidth: 1)
                                })
                VStack(alignment: .leading){
                    HStack( spacing: 2){
                        Text(user.fullName)
                            .foregroundStyle(Color.init(uiColor: .label))
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                        if user.isVerified{
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                                .font(.system(size: 9))
                        }
                    }
                    Text("@" + user.username)
                        .foregroundStyle(Color.init(uiColor: .secondaryLabel))
                        .fontWeight(.bold)
                        .font(.system(size: 10))
                }
                Spacer()
            }
            .padding(.horizontal,20)
            .contentShape(Rectangle())
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
       
    }
}

#Preview {
    SearchProfileButton(user: .mockUser){
        
    }
}
