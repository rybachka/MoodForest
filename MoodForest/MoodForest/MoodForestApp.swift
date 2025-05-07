//
//  MoodForestApp.swift
//  MoodForest
//
//  Created by Mariia Rybak on 07.05.2025.
//

import SwiftUI
import Firebase

@main
struct MoodForestApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
