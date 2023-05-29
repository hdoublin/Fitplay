//
//  ReceviedMessageItemView.swift
//  Fitplay
//
//  Created by Scorpus on 03/28/23.
//

import SwiftUI

struct ReceviedMessageItemView: View {
    var body: some View {
        
        HStack{
            Image("image 4")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 40,height: 40)
                .cornerRadius(25, corners: .allCorners)
                .padding(.top,30)
            VStack(alignment: .leading){
                Text("7:47 PM")
                    .font(.custom(size: 13,weight: .light))
                Text("Testing recevied msg")
                    .font(.custom(size: 15))
                    .padding()
                    .background(Color.black.opacity(0.07))
                    .cornerRadius(20, corners: [.topLeft,.topRight,.bottomRight])
            }
            Spacer()
        }
    }
}

struct ReceviedMessageItemView_Previews: PreviewProvider {
    static var previews: some View {
        ReceviedMessageItemView()
    }
}
