//
//  MainAppView.swift
//  MoodForest
//
//  Created by Mariia Rybak on 07.05.2025.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to MoodForest!")

                Button("Sign Out") {
                    auth.signOut()
                }
            }
            .navigationTitle("MoodForest")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}


//#Preview {
//    MainAppView()
//}
