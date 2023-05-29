//
//  ChatHistoryView.swift
//  Fitplay
//
//  Created by Scorpus on 3/23/23.
//

import SwiftUI

struct ChatHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @State var txtMsg:String = ""
    @State var dateList:[String] = ["January, 21","January, 22"]
    var body: some View {
        VStack{
            HStack{
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.black)
                        .frame(width: 25,height: 25)
                        .padding(5)
                }
                ZStack(alignment: .bottomTrailing){
                    Image("image 4")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 50,height: 50)
                        .cornerRadius(25, corners: .allCorners)
                    Color.gray
                        .frame(width: 10,height: 10)
                        .cornerRadius(5, corners: .allCorners)
                        .padding([.bottom,.trailing],3)
                }
                Text("Michael Wong")
                    .font(.custom(size: 18,weight: .semibold))
                    .padding(.leading,10)
                Spacer()
            }
            ForEach(dateList,id: \.self) { item in
                Text(item)
                    .font(.custom(size: 18,weight: .semibold))
                    .padding(.top,20)
                    .padding(.bottom,10)
                    .foregroundColor(Color(hex: "#8D8D8D"))
                ForEach([0,1,2],id: \.self){ id in
                    if id%2==0{
                        SendMessageItemView()
                    }else{
                        ReceviedMessageItemView()
                    }
                }
            }
            Spacer()
            SendMessageView(txtMsg: $txtMsg)
        }
        .padding(10)
        .navigationBarHidden(true)
    }
}

struct ChatHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHistoryView()
    }
}
