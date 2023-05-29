//
//  FitplayApp.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import Firebase
import SwiftUI

@main
struct FitplayApp: App {
    
    @State var splash = true
    
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var spotifyController = SpotifyController()
    
    @StateObject var data = DataManager()
    
    @AppStorage("dark_mode") var dark = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                
                ContentView()
                
                SplashView(splash: $splash)
                    .zIndex(1)
            }
            .environmentObject(data)
            .environmentObject(spotifyController)
            .onOpenURL { url in spotifyController.setAccessToken(from: url) }
            .preferredColorScheme(dark ? .dark : .light)
            .onAppear {

                data.fetchCategories()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { self.splash = false }
                }
            }
        }
    }
}
