//
//  AboutYou.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI

struct AboutYou: View {
    
    /// Data Manager Object
    @EnvironmentObject var data: DataManager
    
    /// Spotify View Controller
    @EnvironmentObject var spotifyController: SpotifyController
    
    @AppStorage("dark_mode") var dark = false
    
    var body: some View {
        VStack {
            Image("LogoName")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.5, height: 50)
                .padding(.top)
            
            Spacer()
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("About You")
                    .font(Fonts.largeTitle)

                Text("Meet Your New Training Companion:\nThe Ultimate App for Trainers to Create,\nManage and Deliver Dynamic Classes with Ease!")
                    .font(Fonts.description)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 25)
            
            Spacer()
                        
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button {
                        withAnimation { data.user?.type = .trainer }
                    } label: {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("I am\nTrainer")
                                .font(.system(size: 30, weight: .bold))
                                .lineSpacing(5)
                            
                            Text("Ready to create my\nfitness class")
                                .font(.system(size: 12))
                                .lineSpacing(3)
                        }
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 195, height: 256, alignment: .leading)
                        .overlay(alignment: .topTrailing) {
                            ZStack {
                                Circle()
                                    .fill(dark ? Color(.systemBackground) : Color(hex: "#F0F0F0"))
                                    .frame(width: 34, height: 34)
                                    .padding()
                                
                                if data.user?.type == .trainer {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(dark ? Color(.secondarySystemBackground) : .white)
                                .shadow(color: .black.opacity(0.2), radius: 20)
                        )
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
                .padding(.vertical, 20)
            }
            .padding(.top)
            .padding(.vertical, -20)

            
            Spacer()
            
            HStack {
                Button {
                    self.data.update()
                } label: {
                    Text("Skip Intro")
                        .foregroundColor(.primary.opacity(0.5))
                }
                
                Spacer()
                
                NavigationLink {
                    ProfilePhoto()
                        .environmentObject(spotifyController)
                        .environmentObject(data)
                } label: {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(width: 150, height: 50)
                        .background(RoundedRectangle(cornerRadius: 10))
                        .font(Fonts.button)

                }
            }
            .padding(.horizontal, 23)
            
            Spacer()
        }
    }
}

struct AboutYou_Previews: PreviewProvider {
    static var previews: some View {
        AboutYou()
            .environmentObject(DataManager())
            .environmentObject(SpotifyController())
    }
}
