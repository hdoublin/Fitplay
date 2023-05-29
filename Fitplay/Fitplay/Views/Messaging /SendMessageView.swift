//
//  SendMessageView.swift
//  Fitplay
//
//  Created by Scoprus on 03/8/23.
//

import SwiftUI

struct SendMessageView: View {
    @Binding var txtMsg:String
    var body: some View {
        HStack{
            HStack{
                Button {
                    
                } label: {
                    Text("😀")
                        .font(.custom(size: 30))
                }
                TextField("Message", text: $txtMsg)
            }
            .padding(5)
            .background(Color.black.opacity(0.07))
            .cornerRadius(20, corners: .allCorners)
            Button {
                
            } label: {
                Image(systemName: "paperplane")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct SendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageView(txtMsg: .constant(""))
    }
}
