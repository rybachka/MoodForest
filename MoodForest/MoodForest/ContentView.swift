//
//  ContentView.swift
//  MoodForest
//
//  Created by Mariia Rybak on 07.05.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var auth = AuthViewModel()

    var body: some View {
        if auth.isLoading {
            ProgressView("Loading...")
        } else if let _ = auth.user {
            if auth.isProfileComplete {
                MainAppView().environmentObject(auth)
            } else {
                QuestionnaireView(profileCompleted: $auth.isProfileComplete)
            }
        } else {
            LoginView().environmentObject(auth)
        }
    }

}

//#Preview {
//    ContentView()
//}
