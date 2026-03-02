import SwiftUI

struct AccountView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        NavigationStack {
            List {
                // Account section — shows email if signed in, or Sign In link
                Section {
                    if auth.isAuthenticated {
                        if let email = auth.currentUserEmail {
                            Label(email, systemImage: "person.circle.fill")
                                .foregroundStyle(Color.primary)
                        }
                        Button(role: .destructive) {
                            Task {
                                try? await auth.signOut()
                            }
                        } label: {
                            Label("Sign Out", systemImage: "arrow.backward.circle")
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

                Section {
                    NavigationLink(destination: PlanView()) {
                        Label("Plan", systemImage: "creditcard")
                    }
                } header: {
                    Text("Plan")
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
