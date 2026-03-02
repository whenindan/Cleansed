import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isSignUp: Bool = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)

            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.title2.bold())

            // Email Field
            TextField("Enter your email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

            // Password Field
            HStack {
                if isPasswordVisible {
                    TextField("Enter your password", text: $password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField("Enter your password", text: $password)
                }

                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            // Error message
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            // Forgot Password (sign-in only)
            if !isSignUp {
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        // TODO: implement password reset
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }

            // Primary Button
            Button(action: {
                Task { await submit() }
            }) {
                Group {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(isSignUp ? "Sign Up" : "Login")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.darkGray))
                .cornerRadius(30)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .padding(.top, 10)

            // Toggle sign-in / sign-up
            Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
            {
                isSignUp.toggle()
                errorMessage = nil
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            // Divider with "Or Login with"
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
                Text("Or Login with")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .layoutPriority(1)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.top, 10)

            // Social Login Buttons
            HStack(spacing: 16) {
                socialButton(iconName: "f.square.fill", label: "Facebook", color: .blue)
                socialButton(iconName: "g.circle.fill", label: "Google", color: .red)
                socialButton(iconName: "apple.logo", label: "Apple", color: .primary)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Auth action

    private func submit() async {
        isLoading = true
        errorMessage = nil
        do {
            if isSignUp {
                try await auth.signUp(email: email, password: password)
            } else {
                try await auth.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @ViewBuilder
    private func socialButton(iconName: String, label: String, color: Color) -> some View {
        Button(action: {
            // TODO: implement social OAuth
        }) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthManager())
    }
}
