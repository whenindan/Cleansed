import SwiftData
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var showTutorial = false

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
                    Picker(selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    } label: {
                        Label("Appearance", systemImage: "paintbrush.fill")
                    }

                    Button {
                        showTutorial = true
                    } label: {
                        Label("Tutorial", systemImage: "book.fill")
                    }
                    .foregroundStyle(Color.primary)

                    NavigationLink(destination: WidgetSettingsView()) {
                        Label("Widget", systemImage: "square.stack.3d.up.fill")
                    }
                } header: {
                    Text("Settings")
                }

            }
            .navigationTitle("Account")
            .fullScreenCover(isPresented: $showTutorial) {
                TutorialView()
            }
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthManager())
}
