import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        List {
            Section {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: "moon.fill")
                }
            } header: {
                Text("Appearance")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
