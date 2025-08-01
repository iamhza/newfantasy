//
//  New_Fantasy_App_IdeaApp.swift
//  New Fantasy App Idea
//
//  Created by Hamza on 7/31/25.
//

import SwiftUI
import SwiftData

@main
struct New_Fantasy_App_IdeaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
