import FirebaseFirestore
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isProfileComplete = false
    @Published var isLoading = true
    

    init() {
        self.user = Auth.auth().currentUser

        if let user = user {
            checkUserProfileExists(uid: user.uid)
        } else {
            self.isLoading = false // ✅ Stop loading if no user is logged in
        }
    }

    func register(email: String, password: String) {
        self.errorMessage = nil
        self.isLoading = true // ✅ Start loading on register
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false // ✅ Stop loading on failure
                } else if let user = result?.user {
                    self.user = user
                    self.isProfileComplete = false
                    self.isLoading = false // ✅ Stop loading after successful registration
                }
            }
        }
    }

    func login(email: String, password: String) {
        self.errorMessage = nil
        self.isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                } else if let user = result?.user {
                    self.user = user
                    self.checkUserProfileExists(uid: user.uid)
                }
            }
        }
    }

    func checkUserProfileExists(uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { document, error in
            DispatchQueue.main.async {
                self.isProfileComplete = (document?.exists ?? false)
                self.isLoading = false // ✅ Always stop loading after check
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
        self.isProfileComplete = false
        self.errorMessage = nil
    }
}
