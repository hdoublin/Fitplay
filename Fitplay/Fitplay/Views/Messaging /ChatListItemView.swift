//
//  ChatListItemView.swift
//  Fitplay
//
//  Created by Scorpus on 03/28/23.
//

import SwiftUI

struct ChatListItemView: View {
    var body: some View {
        HStack(spacing: 15.0){
            ZStack(alignment: .bottomTrailing){
                Image("image 4")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 60,height: 60)
                    .cornerRadius(30, corners: .allCorners)
                Color.gray
                    .frame(width: 14,height: 14)
                    .cornerRadius(7, corners: .allCorners)
                    .padding([.bottom,.trailing],3)
            }
            VStack(alignment: .leading, spacing: 5.0){
                Text("Gus Fring")
                    .font(.custom(size: 20,weight: .semibold))
                Text("We need to re-asses our strategy.")
                    .font(.custom(size: 16,weight: .regular))
                    .foregroundColor(.black.opacity(0.6))
            }
            Spacer()
        }
    }
}

struct ChatListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListItemView()
    }
}
