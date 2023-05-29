//
//  Premium.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI

struct Premium: View {
    
    @EnvironmentObject var data: DataManager
    
    var body: some View {
        VStack {
            Image("LogoName")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.5, height: 50)
                .padding(.top)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Premium")
                    .font(Fonts.largeTitle)
                
                Text("Unleash Your Creativity and Take Your Training to the Next Level: Create Unlimited Classes with Our Trainer’s Tool.")
                    .font(Fonts.description)
                    .minimumScaleFactor(0.7)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
            
                        
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.primary.opacity(0.2))
                    
                VStack(spacing: 0) {
                    
                    HStack {
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "#E6863B"))
                        
                        Text("Unlimited Playlists")
                            .font(.system(size: 23))
                        
                        Spacer()
                    }
                    .padding(.bottom)
                    
                    HStack {
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "#E6863B"))
                        
                        Text("Zero Ads")
                            .font(.system(size: 23))

                        Spacer()
                    }
                    
                    Text("We won't serve you with ads")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#3E3E3E"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 25)
                }
                .padding(.leading)
            }
            .frame(width: width * 0.9, height: 130)
            .overlay(alignment: .top) {
                ZStack {
                    Capsule()
                        .fill(Color(.systemBackground), strokeBorder: .primary.opacity(0.2))
                    
                    Text("Enhance Your Experience")
                    
                        .font(.system(size: 12))
                }
                    .frame(width: 170, height: 25)
                    .offset(y: -12.5)
            }
            .padding(.top)
            
            Spacer()
            
            Button {
                self.data.update()
            } label: {
                Text("Starting At $70.00")
                    .foregroundColor(.white)
                    .frame(width: width * 0.85, height: 50)
                    .font(Fonts.button)
                    .background(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom, 30)
            
            HStack(spacing: 0) {
                
                Rectangle()
                    .fill(.primary.opacity(0.4))
                    .frame(height: 1.5)
                
                Text("OR")
                    .foregroundColor(.primary.opacity(0.5))
                    .padding(.horizontal)
                
                Rectangle()
                    .fill(.primary.opacity(0.4))
                    .frame(height: 1.5)
            }
            .padding(.horizontal)
            
            Button {
                self.data.update()
            } label: {
                Text("Continue With Basic")
                    .foregroundColor(.white)
                    .frame(width: width * 0.85, height: 50)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#142643")))
                    .font(Fonts.button)
            }
            .padding(.top, 30)
            
            Group {
                Spacer()
                Spacer()
                Spacer()
            }
        }
    }
}

struct Premium_Previews: PreviewProvider {
    static var previews: some View {
        Premium()
            .environmentObject(DataManager())
    }
}
