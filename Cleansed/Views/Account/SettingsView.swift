import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some View {
        List {
            Section {
                Picker(selection: $appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                } label: {
                    Label("Appearance", systemImage: "paintbrush.fill")
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
