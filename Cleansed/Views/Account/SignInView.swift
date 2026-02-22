import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)

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

            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // Placeholder
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            // Login Button
            Button(action: {
                // Placeholder
            }) {
                Text("Login")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.darkGray))
                    .cornerRadius(30)
            }
            .padding(.top, 10)

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
                // Facebook
                socialButton(iconName: "f.square.fill", label: "Facebook", color: .blue)

                // Google
                socialButton(iconName: "g.circle.fill", label: "Google", color: .red)

                // Apple
                socialButton(iconName: "apple.logo", label: "Apple", color: .primary)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func socialButton(iconName: String, label: String, color: Color) -> some View {
        Button(action: {
            // Placeholder
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
    }
}
