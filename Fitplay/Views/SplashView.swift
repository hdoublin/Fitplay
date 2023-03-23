//
//  SplashView.swift
//  Fitplay
//
//  Created by Scorpus on 3/23/23.
//

import SwiftUI

struct SplashView: View {

        @State var isActive : Bool = false
        @State private var size = 0.8
        @State private var opacity = 0.5
        
        // Customise your SplashScreen here
        var body: some View {
    
            if isActive {
                ContentView()
            } else {
                VStack {
                    VStack {
                        Image("YogaGirl")
                            .resizable()
                            .frame(width: 325, height: 194)
                            .aspectRatio(contentMode: .fit)
                            .position(x:185,y:265 )

                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.00
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }

    struct SplashView_Previews: PreviewProvider {
        static var previews: some View {
            SplashView()
        }
    }
