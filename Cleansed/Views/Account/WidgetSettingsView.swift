//
//  WidgetSettingsView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/17/26.
//

import SwiftUI

struct WidgetSettingsView: View {
    let settings = WidgetSettings.shared
    @State private var showResetAlert = false
    @State private var selectedColor: Color

    // AppStorage properties for bindings
    @AppStorage("widget.isLowercase", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var isLowercase: Bool = false

    @AppStorage("widget.fontSize", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var fontSize: Int = 13

    @AppStorage("widget.alignment", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var alignment: String = "leading"

    @AppStorage(
        "widget.horizontalPadding", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var horizontalPadding: Int = 12

    @AppStorage(
        "widget.verticalPadding", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var verticalPadding: Int = 8

    @AppStorage("widget.todosSpacing", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var todosSpacing: Int = 8

    @AppStorage(
        "widget.useCustomBackground", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var useCustomBackground: Bool = false

    init() {
        let settings = WidgetSettings.shared
        _selectedColor = State(initialValue: settings.backgroundColorValue)
    }

    var body: some View {
        List {
            // Preview Section
            Section {
                WidgetPreviewView()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            // Text Settings
            Section {
                // Lowercase Toggle
                HStack {
                    Image(systemName: "textformat")
                        .frame(width: 30)
                    Text("Lowercase")
                    Spacer()
                    Toggle("", isOn: $isLowercase)
                        .onChange(of: isLowercase) { _, _ in
                            TodoManager.shared.reloadWidgets()
                        }
                }

                // Font Size
                HStack {
                    Image(systemName: "textformat.size")
                        .frame(width: 30)
                    Text("Font size: \(fontSize)")
                    Spacer()
                    Stepper("", value: $fontSize, in: 10...20)
                        .onChange(of: fontSize) { _, _ in
                            TodoManager.shared.reloadWidgets()
                        }
                }

                // Alignment
                HStack {
                    Image(systemName: "text.alignleft")
                        .frame(width: 30)
                    Text("Alignment")
                    Spacer()
                    Picker("", selection: $alignment) {
                        Text("Leading").tag("leading")
                        Text("Center").tag("center")
                        Text("Trailing").tag("trailing")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: alignment) { _, _ in
                        TodoManager.shared.reloadWidgets()
                    }
                }
            } header: {
                Text("Text")
            }

            // Spacing Settings
            Section {
                // Horizontal Padding
                HStack {
                    Image(systemName: "arrow.left.and.right")
                        .frame(width: 30)
                    Text("Horizontal padding: \(horizontalPadding)")
                    Spacer()
                    Stepper("", value: $horizontalPadding, in: 0...30)
                        .onChange(of: horizontalPadding) { _, _ in
                            TodoManager.shared.reloadWidgets()
                        }
                }

                // Vertical Padding
                HStack {
                    Image(systemName: "arrow.up.and.down")
                        .frame(width: 30)
                    Text("Vertical padding: \(verticalPadding)")
                    Spacer()
                    Stepper("", value: $verticalPadding, in: 0...30)
                        .onChange(of: verticalPadding) { _, _ in
                            TodoManager.shared.reloadWidgets()
                        }
                }

                // Todos Spacing
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .frame(width: 30)
                    Text("Todos spacing: \(todosSpacing)")
                    Spacer()
                    Stepper("", value: $todosSpacing, in: 0...30)
                        .onChange(of: todosSpacing) { _, _ in
                            TodoManager.shared.reloadWidgets()
                        }
                }
            } header: {
                Text("Spacing")
            }

            // Background Settings
            Section {
                // Custom Background Toggle
                HStack {
                    Image(systemName: "paintpalette")
                        .frame(width: 30)
                    Text("Custom background color")
                    Spacer()
                    Toggle("", isOn: $useCustomBackground)
                        .onChange(of: useCustomBackground) { _, _ in
                            TodoManager.shared.reloadWidgets()
                        }
                }

                // Color Picker (conditional)
                if useCustomBackground {
                    ColorPicker("Background Color", selection: $selectedColor)
                        .onChange(of: selectedColor) { _, newColor in
                            settings.backgroundColor = newColor.toHex()
                            TodoManager.shared.reloadWidgets()
                        }
                }
            } header: {
                Text("Appearance")
            }

            // Reset Section
            Section {
                Button(action: {
                    showResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset to default")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Widget Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                settings.resetToDefaults()
                selectedColor = settings.backgroundColorValue
            }
        } message: {
            Text("Are you sure you want to reset all widget settings to default?")
        }
    }
}

#Preview {
    NavigationStack {
        WidgetSettingsView()
    }
}
