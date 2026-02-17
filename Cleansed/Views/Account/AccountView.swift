import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        // Placeholder action
                    }) {
                        Label("Sign in", systemImage: "person.circle")
                            .foregroundStyle(Color.primary)
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
}
