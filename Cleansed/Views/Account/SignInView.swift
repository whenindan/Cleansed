import SwiftData
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var localTodos: [TodoItem]
    @Query private var localHabits: [Habit]

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isSignUp: Bool = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 10)

            // Logo
            Image(colorScheme == .dark ? "logo-dark" : "logo-light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .padding(.bottom, 10)

            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.title2.bold())
                .textCase(.lowercase)

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
                Button(action: { isPasswordVisible.toggle() }) {
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

            // Forgot Password
            if !isSignUp {
                HStack {
                    Spacer()
                    Button("Forgot Password?") {}
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Primary auth button
            Button(action: { Task { await submit() } }) {
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

            // Divider
            HStack {
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
                Text("or").font(.caption).foregroundColor(.secondary).padding(.horizontal, 8)
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.vertical, 4)

            // Google sign-in
            Button(action: {
                Task {
                    isLoading = true
                    errorMessage = nil
                    do {
                        try await auth.signInWithGoogle()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    isLoading = false
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "globe")
                    Text("Continue with Google")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .foregroundColor(Color(.label))
                .cornerRadius(30)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            }
            .disabled(isLoading)

            // Toggle sign-in / sign-up
            Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
            {
                isSignUp.toggle()
                errorMessage = nil
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            // Guest mode
            Button("Continue as Guest") {
                auth.continueAsGuest()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Auth

    private func submit() async {
        isLoading = true
        errorMessage = nil
        let wasGuest = auth.isGuest

        // Snapshot before auth clears guest state
        let todosToMigrate = wasGuest ? localTodos : []
        let habitsToMigrate = wasGuest ? localHabits : []

        do {
            if isSignUp {
                try await auth.signUp(email: email, password: password)
            } else {
                try await auth.signIn(email: email, password: password)
            }

            // Migrate guest data if we just transitioned from guest to account
            if wasGuest, let userId = auth.currentUserId {
                await DataSyncManager.shared.migrateGuestData(
                    userId: userId,
                    localTodos: todosToMigrate,
                    localHabits: habitsToMigrate,
                    context: modelContext
                )
            } else if let userId = auth.currentUserId {
                // Normal sign-in: load account data from Supabase
                await DataSyncManager.shared.loadFromSupabase(userId: userId, context: modelContext)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthManager())
    }
}
