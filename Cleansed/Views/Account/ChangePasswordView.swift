import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var didSucceed = false

    private var validationError: String? {
        if newPassword.count < 6 { return "Password must be at least 6 characters." }
        if newPassword != confirmPassword { return "Passwords do not match." }
        return nil
    }

    var body: some View {
        List {
            Section {
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm Password", text: $confirmPassword)
            }

            Section {
                Button {
                    Task { await save() }
                } label: {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Save Password")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Password Updated", isPresented: $didSucceed) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your password has been changed successfully.")
        }
    }

    private func save() async {
        guard let error = validationError else {
            isLoading = true
            errorMessage = nil
            do {
                try await auth.changePassword(newPassword: newPassword)
                isLoading = false
                didSucceed = true
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            return
        }
        errorMessage = error
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
            .environmentObject(AuthManager())
    }
}
