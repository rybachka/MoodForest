import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(isRegistering ? "Register" : "Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button(action: {
                    if isRegistering {
                        auth.register(email: email, password: password)
                    } else {
                        auth.login(email: email, password: password)
                    }
                }) {
                    Text(isRegistering ? "Create Account" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    isRegistering.toggle()
                    
                }) {
                    Text(isRegistering ? "Already have an account?" : "Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                if let error = auth.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
