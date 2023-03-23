//
//  FitplayApp.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import SwiftUI

@main
struct FitplayApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
