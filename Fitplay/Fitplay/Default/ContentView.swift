//
//  ContentView.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @AppStorage("status") var status = false
    
    @EnvironmentObject var data: DataManager
    
    /// Spotify View Controller
    @EnvironmentObject var spotifyController: SpotifyController

    var body: some View {
        ZStack {
            NavigationView {
                if status && data.user?.boarded == true {
                    HomeView()
                        .environmentObject(data)
                        .onAppear { data.fetch() }
                } else if status {
                    AboutYou()
                        .environmentObject(spotifyController)
                        .environmentObject(data)
                        .onAppear { data.fetch() }
                } else {
                    GettingStarted()
                }
            }
            
            CustomLoading($data.handle)
            
            CustomAlert($data.handle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
