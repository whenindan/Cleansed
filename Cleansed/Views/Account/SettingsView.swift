import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var showTutorial = false

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
            
            Section {
                Button {
                    showTutorial = true
                } label: {
                    Label("Show Tutorial", systemImage: "book.fill")
                }
                .foregroundStyle(Color.primary)
            } header: {
                Text("Help")
            }
        }
        .navigationTitle("Settings")
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
    }
}

#Preview {
    SettingsView()
}
