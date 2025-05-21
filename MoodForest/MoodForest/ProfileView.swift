import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var firstName = ""
    @State private var nickname = ""
    @State private var birthday = Date()
    @State private var email = ""
    @State private var profileImage: Image? = nil
    @State private var showAlreadyAuthorizedAlert = false
    @State private var showLocationAlreadyGrantedAlert = false
    @State private var locationAlertMessage: String? = nil
    @State private var showLocationAlert = false
    @EnvironmentObject var auth: AuthViewModel


    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Optional profile image placeholder
                profileImage?
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding()

                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)

                TextField("Nickname", text: $nickname)
                    .textFieldStyle(.roundedBorder)

                // Enable Location Access button
                Button("Enable Location Access") {
                    print("🔘 Button tapped")

                    let status = locationManager.status ?? .notDetermined

                    switch status {
                    case .authorizedAlways, .authorizedWhenInUse:
                        locationAlertMessage = "You are already sharing your location with the app. To stop sharing, go to Settings and change your privacy settings."
                        showLocationAlert = true
                    case .denied, .restricted:
                        locationAlertMessage = "You have declined location sharing with the app. To resume sharing, go to Settings and change your privacy settings."
                        showLocationAlert = true
                    case .notDetermined:
                        print("📍 Calling requestWhenInUseAuthorization")
                        locationManager.requestLocationPermission()
                    @unknown default:
                        break
                    }
                }
                .alert("Location Access", isPresented: $showLocationAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(locationAlertMessage ?? "")
                }

                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

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
                Button("Sign Out") {
                    auth.signOut()
                }
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
                loadProfile()
            }
        }
    }

    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        email = Auth.auth().currentUser?.email ?? ""

        Firestore.firestore().collection("users").document(uid).getDocument { doc, _ in
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
