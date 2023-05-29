//
//  ConnectWatch.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import WatchConnectivity
import SwiftUI

struct ConnectWatch: View {
    
    /// Data Manager Object
    @EnvironmentObject var data: DataManager
    
    /// Spotify View Controller
    @EnvironmentObject var spotifyController: SpotifyController
    
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
                    Text("Connect Apple\nWatch")
                        .font(Fonts.largeTitle)
                        .minimumScaleFactor(0.7)
                    
                    Text("Revolutionize your class planning: access your notes anytime")
                        .font(Fonts.description)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 25)
            }
            
            Spacer()
            
            Image("Watch")
            
            Spacer()

            Button {
//                WCSession().
            } label: {
                Text("Connect")
                    .font(Fonts.button)
                    .foregroundColor(.white)
                    .frame(width: width * 0.85, height: 50)
                    .background(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.bottom, 20)
            
            HStack {
                Text("Don't have an Apple Watch?")
                    .foregroundColor(.secondary)
                Button {
                    
                } label: {
                    Text("Skip")
                        .fontWeight(.medium)
                }
            }
            .font(.footnote)
                        
            
        }
    }
}

struct ConnectWatch_Previews: PreviewProvider {
    static var previews: some View {
        ConnectWatch()
            .environmentObject(DataManager())
    }
}
