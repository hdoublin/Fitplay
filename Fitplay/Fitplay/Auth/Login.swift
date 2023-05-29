//
//  Login.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI

struct Login: View {
    
    /// Toggles Between Login And Signup
    @Binding var toggle: Bool
    
    /// Auth Manager Object
    @EnvironmentObject var auth: AuthManager
    
    @StateObject var apple = SignInWithApple()

    var body: some View {
        VStack {
            Image("LogoName")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.5, height: 50)
                .padding(.top)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Log In")
                    .font(Fonts.largeTitle)
                
                Text("To Access Your Trainer’s Tool and Take Your Classes to the Next Level.")
                    .font(Fonts.description)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
                        
            Group {
                AuthTextField("Email Address", value: $auth.email) {
                    Text("@")
                        .font(.system(size: 30, weight: .bold, design: .default))
                }
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .padding(.top, 30)
                
                AuthTextField("Password", value: $auth.password, password: true) {
                    Image(systemName: "lock")
                        .font(.system(size: 30, weight: .medium, design: .default))
                }
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .padding(.top)
            }
            
            Spacer()
            
            Button {
                auth.logIn()
            } label: {
                Text("Login")
                    .font(Fonts.button)
                    .foregroundColor(.white)
                    .frame(width: width * 0.85, height: 55)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 15))
            }
            
            HStack {
                
                VStack { Divider() }
                
                Text("OR")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .padding(.horizontal)
                
                VStack { Divider() }
            }
            .padding()
            
            Button {
                apple.startSignInWithAppleFlow { email, name in
                    auth.user.name = name
                    auth.saveData()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 21, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    Text("Sign In With Apple")
                        .font(Fonts.button)
                        .foregroundColor(.primary)

                }
                .frame(height: 55)
                .frame(maxWidth: width * 0.85)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 15))

            }
            .padding(.bottom, 40)
            
            HStack {
                Text("New To FitPlay?")
                    .foregroundColor(Color.gray)
                
                Button("Register") {
                    withAnimation { toggle.toggle() }
                }
            }
            .padding(.vertical)
        }
        .alert(auth.message, isPresented: $auth.alert) {
            
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(toggle: .constant(false))
            .environmentObject(AuthManager())
    }
}
