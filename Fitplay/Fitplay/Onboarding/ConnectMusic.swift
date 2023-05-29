//
//  ConnectMusic.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import MusicKit
import SwiftUI

struct ConnectMusic: View {
    
    @State var isSpotify = true
    
    /// Spotify View Controller
    @EnvironmentObject var spotifyController: SpotifyController
    
    /// Apple Music Controller
    @StateObject var appleMusicController = AppleMusicController()
    
    @EnvironmentObject var data: DataManager
    
    @State var move = false
    
    @State var selection = 0
    
    @ViewBuilder
    var body: some View {
        VStack {
            Group {
                Image("LogoName")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.5, height: 50)
                    .padding(.top)
                
                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Connect to\n\(isSpotify ? "Spotify" : "Apple Music")")
                        .font(Fonts.largeTitle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 25)
                .padding(.top, 20)
            }
                        
            HStack {
                ForEach(0..<2) { int in
                    Circle()
                        .fill(selection == int ? Color(hex: "#707070") : Color(hex: "#DEDEDE"))
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.bottom)
                        
            TabView(selection: $selection) {
               view(spotify: true)
                    .tag(0)
                
                view(spotify: false)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            

            HStack {
                Text("Don't have \(isSpotify ? "Spotify" : "Apple Music")?")
                    .foregroundColor(.secondary)
                
                Button {
                    withAnimation { move.toggle() }
                } label: {
                    Text("Skip")
                        .fontWeight(.medium)
                }
            }
            .font(Fonts.footnote)
        }
        .background(
            NavigationLink(isActive: $move) {
                Premium()
                    .environmentObject(data)
            } label: {
                EmptyView()
            }
        )
    }
    
    func view(spotify: Bool) -> some View {
        VStack {
            Image("\(spotify ? "Spotify" : "AppleMusic")Phone")
                .resizable()
                .scaledToFit()
                .frame(height: height * 0.4)
            
            Spacer()

            Button {
                if spotify {
                    spotifyController.logInCompletion = { token in
                        data.user?.spotifyAccessToken = token
                        move.toggle()
                        print("token: \(token)")
                    }
                    spotifyController.spotifyAuthVC()
                } else {
                    Task {
                        await appleMusicController.requestMusicAuthorization()
                        
                        if appleMusicController.isAuthorizedForMusicKit {
                            move.toggle()
                        }
                    }
                }
            } label: {
                Text("Connect to \(spotify ? "Spotify" : "Apple Music")")
                    .foregroundColor(.white)
                    .font(Fonts.button)
                    .frame(width: width * 0.85, height: 50)
                    .background(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.bottom, 8)
        }
    }
}

struct ConnectMusic_Previews: PreviewProvider {
    static var previews: some View {
        ConnectMusic()
            .environmentObject(DataManager())
            .environmentObject(SpotifyController())
    }
}
