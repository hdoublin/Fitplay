//
//  SendMessageItemView.swift
//  Fitplay
//
//  Created by Scorpus on 03/28/23.
//

import SwiftUI

struct SendMessageItemView: View {
    var body: some View {
        HStack{
            Spacer()
            VStack(alignment: .leading){
                Text("7:47 PM")
                    .font(.custom(size: 13,weight: .light))
                Text("Testing send msg")
                    .font(.custom(size: 15))
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(hex: "#E07526"))
                    .cornerRadius(20, corners: [.topLeft,.topRight,.bottomLeft])
            }
        }
    }
}

struct SendMessageItemView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageItemView()
    }
}
