import FirebaseFirestore
//import FirebaseFirestoreSwift
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
        }
    }

    func register(email: String, password: String) {
        self.errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else if let user = result?.user {
                self.user = user
                self.isProfileComplete = false
            }
        }
    }

    func login(email: String, password: String) {
        self.errorMessage = nil
        self.isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            } else if let user = result?.user {
                self.user = user
                self.checkUserProfileExists(uid: user.uid)
            }
        }
    }

    func checkUserProfileExists(uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                self.isProfileComplete = true
            } else {
                self.isProfileComplete = false
            }
            self.isLoading = false
        }
    }


    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
        self.isProfileComplete = false
        self.errorMessage = nil
    }
}
