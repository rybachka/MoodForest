//
//  QuestionnaireView.swift
//  MoodForest
//
//  Created by Mariia Rybak on 07.05.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct QuestionnaireView: View {
    @State private var firstName = ""
    @State private var nickname = ""
    @State private var birthday = Date()
    @State private var showError = false
    
    @Binding var profileCompleted: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tell us about yourself").font(.title2)
            
            TextField("First Name", text: $firstName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Nickname", text: $nickname)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("Birthday (optional)", selection: $birthday, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
            
            Button("Continue") {
                if firstName.isEmpty || nickname.isEmpty {
                    showError = true
                } else {
                    saveProfile()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if showError {
                Text("Please enter both first name and nickname.")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    func saveProfile() {
        guard let user = Auth.auth().currentUser,
                  let email = user.email else {
                self.showError = true
                return
            }
        let uid = user.uid
        
        // Check if nickname already exists
        let usersRef = Firestore.firestore().collection("users")
        usersRef.whereField("nickname", isEqualTo: nickname).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking nickname: \(error)")
                self.showError = true
                return
            }
            
            // If nickname already exists (and not the current user), show error
            if let documents = snapshot?.documents, !documents.isEmpty {
                self.showError = true
                return
            }
            
            // No duplicates → proceed to save
            let profile = UserProfile(uid: uid, firstName: firstName, nickname: nickname, birthday: birthday, email: email)
            do {
                try usersRef.document(uid).setData(from: profile) { error in
                    if error == nil {
                        profileCompleted = true
                    } else {
                        print("Error saving profile: \(error?.localizedDescription ?? "")")
                        self.showError = true
                    }
                }
            } catch {
                print("Encoding error: \(error)")
                self.showError = true
            }
        }
    }
}


//#Preview {
//    QuestionnaireView(profileCompleted: .constant(false))}
