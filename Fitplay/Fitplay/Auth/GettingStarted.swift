//
//  GettingStarted.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI

struct GettingStarted: View {
    
    /// Covers The Screen With log In/Sign Up Info
    @State var cover = false
    
    /// Is The Screen Sign Up
    @State var signUp = false
    
    /// Auth Manager Object
    @StateObject var auth = AuthManager()
    
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
                Text("Welcome")
                    .font(Fonts.largeTitle)

                Text("Train and live the new experience of\nexercising at your convenience")
                    .font(Fonts.description)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 25)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button {
                    signUp = true
                } label: {
                    Text("Try Now")
                        .font(Fonts.button)
                        .foregroundColor(.white)
                        .frame(width: width * 0.85, height: 55)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 15))
                }
                
                Button {
                    cover.toggle()
                } label: {
                    Text("Login")
                        .font(Fonts.button)
                        .foregroundColor(.primary)
                        .frame(width: width * 0.85, height: 55)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 15))
                }
            }
            
            Spacer(minLength: 60)
            
            Button {
                
            } label: {
                Text("Choose Language")
            }
            .padding(.bottom)
        }
        .onChange(of: signUp) { newValue in
            if !cover { cover.toggle() }
        }
        .fullScreenCover(isPresented: $cover) {
            ScrollView(.vertical, showsIndicators: false) {
                if signUp {
                    Signup(toggle: $signUp)
                } else {
                    Login(toggle: $signUp)
                }
            }
            .environmentObject(auth)
        }
    }
}

struct GettingStarted_Previews: PreviewProvider {
    static var previews: some View {
        GettingStarted()
    }
}

extension View {
    
    var width: CGFloat { UIScreen.main.bounds.width }
    
    var height: CGFloat { UIScreen.main.bounds.height }
}
