//
//  ProfilePhoto.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI

struct ProfilePhoto: View {
    
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
                    Text("Add Photo")
                        .font(Fonts.largeTitle)
                    
                    Text("Add a Personal Touch: Upload Your Profile Photo.")
                        .font(Fonts.description)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 25)
            }
            
            Spacer()
            
            Group {
                if let image = data.image {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFit()
                    
                } else {
                    Image("defaultProfile")
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFit()
                }
            }
            .frame(height: 200)
            
            Spacer()
            Spacer()
                        
            HStack {
                if data.image == nil {
                    NavigationLink {
                        ConnectMusic()
                            .environmentObject(spotifyController)
                            .environmentObject(data)
                    } label: {
                        Text("Skip For Now")
                            .foregroundColor(.primary.opacity(0.5))
                    }
                    Spacer()
                }
                                
                if data.image == nil {
                    Button {
                        data.selectImage.toggle()
                    } label: {
                        Text("\(Image(systemName: "plus")) Add Photo")
                            .font(Fonts.button)
                            .foregroundColor(.white)
                            .frame(width: 150, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10))
                            .font(Fonts.button)

                    }
                } else {
                    NavigationLink {
                        ConnectMusic()
                            .environmentObject(spotifyController)
                            .environmentObject(data)
                    } label: {
                        Text("Continue")
                            .foregroundColor(.white)
                            .frame(width: width * 0.9, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal, data.image == nil ? 23 : 0)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $data.selectImage) {
            ImagePicker(image: $data.image)
        }
    }
}

struct ProfilePhoto_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePhoto()
            .environmentObject(DataManager())
            .environmentObject(SpotifyController())
    }
}
