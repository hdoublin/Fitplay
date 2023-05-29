//
//  SplashView.swift
//  Fitplay
//
//  Created by Scorpus on 3/23/23.
//

import SwiftUI

struct SplashView: View {
    
    @Binding var splash: Bool
    
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    // Customise your SplashScreen here
    var body: some View {
        Image("YogaGirl")
            .resizable()
            .frame(width: 325, height: 194)
            .aspectRatio(contentMode: .fit)
            .position(x:185,y:265 )
            .scaleEffect(size)
            .opacity(opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .frame(height: splash ? nil : 0)
            .opacity(splash ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 0.9
                    self.opacity = 1.00
                }
            }
    }
}
