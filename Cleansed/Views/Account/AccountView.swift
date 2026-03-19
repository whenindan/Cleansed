import SwiftData
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                // Account section
                Section {
                    if auth.isAuthenticated {
                        if let email = auth.currentUserEmail {
                            Label(email, systemImage: "person.circle.fill")
                                .foregroundStyle(Color.primary)
                        }
                        Button(role: .destructive) {
                            Task {
                                // Clear local mirror data before signing out
                                DataSyncManager.shared.clearLocalData(context: modelContext)
                                try? await auth.signOut()
                            }
                        } label: {
                            Label("Sign Out", systemImage: "arrow.backward.circle")
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
                    Text("Account")
                }

                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                    NavigationLink(destination: WidgetSettingsView()) {
                        Label("Widget", systemImage: "square.stack.3d.up.fill")
                    }
                } header: {
                    Text("Settings")
                }

            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthManager())
}
