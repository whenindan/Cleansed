import SwiftData
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            Section {
                if auth.isAuthenticated {
                    if let email = auth.currentUserEmail {
                        Label(email, systemImage: "person.circle.fill")
                            .foregroundStyle(Color.primary)
                    }
                    
                    Button {
                        // Placeholder for Change Password
                    } label: {
                        Label("Change Password", systemImage: "key.fill")
                    }
                    .foregroundStyle(Color.primary)
                    
                    Button(role: .destructive) {
                        Task {
                            // Clear local mirror data before signing out
                            DataSyncManager.shared.clearLocalData(context: modelContext)
                            try? await auth.signOut()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "arrow.backward.circle")
                    }
                    
                    Button(role: .destructive) {
                        // Placeholder for Delete Account
                    } label: {
                        Label("Delete Account", systemImage: "trash.fill")
                    }
                } else if auth.isGuest {
                    Label("Guest", systemImage: "person.circle")
                        .foregroundStyle(Color.secondary)
                    NavigationLink(destination: SignInView().environmentObject(auth)) {
                        Label("Create Account or Sign In", systemImage: "arrow.right.circle")
                            .foregroundStyle(Color.primary)
                    }
                } else {
                    NavigationLink(destination: SignInView().environmentObject(auth)) {
                        Label("Sign in", systemImage: "person.circle")
                            .foregroundStyle(Color.primary)
                    }
                }
            } header: {
                Text("Account Management")
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
