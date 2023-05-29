//
//  Signup.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI

struct Signup: View {
    
    /// Toggles Between Login And Signup
    @Binding var toggle: Bool
    
    /// Auth Manager Object
    @EnvironmentObject var auth: AuthManager
    
    var body: some View {
        VStack {
            Image("LogoName")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.5, height: 50)
                .padding(.top)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Sign Up")
                    .font(Fonts.largeTitle)

                Text("Join the Ultimate Trainer’s Tool by Creating Your Classes Today!")
                    .font(Fonts.description)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
                        
            AuthTextField("Email Address", value: $auth.email) {
                Text("@")
                    .font(.system(size: 30, weight: .bold, design: .default))
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .padding(.top, 30)
            
            AuthTextField("Full Name", value: $auth.user.name) {
                Image(systemName: "person")
                    .font(.system(size: 30, weight: .medium, design: .default))
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .padding(.top)
            
            AuthTextField("Mobile", value: $auth.user.phone) {
                Image(systemName: "phone")
                    .font(.system(size: 30, weight: .medium, design: .default))
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .padding(.top)
            
            AuthTextField("Password", value: $auth.password, password: true) {
                Image(systemName: "lock")
                    .font(.system(size: 30, weight: .medium, design: .default))
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .padding(.top)
            
            Group {
                Spacer()
                Spacer()
                
                Button {
                    auth.signUp()
                } label: {
                    Text("Continue")
                        .font(Fonts.button)
                        .foregroundColor(.white)
                        .frame(width: width * 0.85, height: 50)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 15))
                }
            }
            
            HStack {
                Text("Joined Us Before?")
                    .foregroundColor(.secondary)
                
                Button("Login") {
                    withAnimation { toggle.toggle() }
                }
            }
            .padding(.vertical)
            .font(Fonts.footnote)
        }
        .alert(auth.message, isPresented: $auth.alert) {
            
        }
    }
}

struct Signup_Previews: PreviewProvider {
    static var previews: some View {
        Signup(toggle: .constant(true))
            .environmentObject(AuthManager())
    }
}

struct AuthTextField: View {
    
    /// Title Of The Textfield
    let title: String
    
    /// Image Name Of The Textfield Image
    let image: AnyView
    
    /// Value Of The TextField
    @Binding var value: String
    
    let isPassword: Bool
    
    init(_ title: String, value: Binding<String>, password: Bool = false, image: @escaping () -> some View) {
        self.title = title
        self._value = value
        self.isPassword = password
        self.image = AnyView(image())
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            image
                .padding(.bottom, 3)
                .frame(width: 40)
                .foregroundColor(Color.gray)
                .padding(.trailing, 10)
            
            VStack {
                
                if isPassword {
                    SecureField(title, text: $value)
                        .font(.system(size: 20, weight: .regular, design: .default))
                } else {
                    TextField(title, text: $value)
                        .font(.system(size: 20, weight: .regular, design: .default))
                }
                
                Divider()
            }
        }
        .frame(width: width * 0.85, height: 50)
    }
}
