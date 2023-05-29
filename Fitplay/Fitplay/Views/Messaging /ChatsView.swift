//
//  ChatsView.swift
//  Fitplay
//
//  Created by Scorpus on 3/23/23.
//

import SwiftUI

struct ChatsView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(alignment: .leading){
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
                Spacer()
            }
            HStack{
                Text("Chat")
                    .font(.custom(size: 30))
                Spacer()
            }
            List{
                ForEach([0,1,2],id: \.self){ id in
                    NavigationLink {
                        ChatHistoryView()
                            .tint(.black)
                    } label: {
                        ChatListItemView()
                    }
                }
            }
            .listStyle(.plain)
            Spacer()
        }
        .padding(10)
        .navigationBarHidden(true)
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
