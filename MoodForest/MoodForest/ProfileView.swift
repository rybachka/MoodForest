import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var firstName = ""
    @State private var nickname = ""
    @State private var birthday = Date()
    @State private var email = ""
    @State private var profileImage: Image? = nil
    @Environment(\.dismiss) var dismiss


    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Profile Image (placeholder, can add image picker later)
                profileImage?
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding()
                
                // Editable fields
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Nickname", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                
                Text("Email: \(email)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Button("Save Changes") {
                    saveProfileChanges()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
            .onAppear {
                loadProfile() // ✅ This loads the data when view opens
            }
        }
    }

    

    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        email = Auth.auth().currentUser?.email ?? ""

        Firestore.firestore().collection("users").document(uid).getDocument { doc, error in
            if let data = doc?.data() {
                self.firstName = data["firstName"] as? String ?? ""
                self.nickname = data["nickname"] as? String ?? ""
                if let timestamp = data["birthday"] as? Timestamp {
                    self.birthday = timestamp.dateValue()
                }
            }
        }
    }

    func saveProfileChanges() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).updateData([
            "firstName": firstName,
            "nickname": nickname,
            "birthday": birthday
        ])
    }
}
