//
//  WidgetSettingsView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/17/26.
//

import SwiftUI
import WidgetKit

struct WidgetSettingsView: View {
    let settings = WidgetSettings.shared
    @State private var showResetAlert = false
    @State private var selectedFamily: WidgetFamily = .systemLarge
    @State private var selectedColor: Color = .black

    // MARK: - AppStorage Properties
    // Using explicit groups for Small, Medium, Large

    // Large (Default)
    @AppStorage(
        "widget.large.isLowercase", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeIsLowercase: Bool = false
    @AppStorage(
        "widget.large.fontSize", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeFontSize: Int = 13
    @AppStorage(
        "widget.large.alignment", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeAlignment: String = "leading"
    @AppStorage(
        "widget.large.horizontalPadding",
        store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeHorizontalPadding: Int = 12
    @AppStorage(
        "widget.large.verticalPadding", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeVerticalPadding: Int = 8
    @AppStorage(
        "widget.large.todosSpacing", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeTodosSpacing: Int = 8
    @AppStorage(
        "widget.large.useCustomBackground",
        store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeUseCustomBackground: Bool = false
    @AppStorage(
        "widget.large.backgroundColor", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var largeBackgroundColor: String = "#1C1C1E"

    // Medium
    @AppStorage(
        "widget.medium.isLowercase", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var mediumIsLowercase: Bool = false
    @AppStorage(
        "widget.medium.fontSize", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var mediumFontSize: Int = 13
    @AppStorage(
        "widget.medium.alignment", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var mediumAlignment: String = "leading"
    @AppStorage(
        "widget.medium.horizontalPadding",
        store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var mediumHorizontalPadding: Int = 14
    @AppStorage(
        "widget.medium.verticalPadding", store: UserDefaults(suiteName: "group.com.cleansed.shared")
    )
    private var mediumVerticalPadding: Int = 10
    @AppStorage(
        "widget.medium.todosSpacing", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var mediumTodosSpacing: Int = 8
    @AppStorage(
        "widget.medium.useCustomBackground",
        store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var mediumUseCustomBackground: Bool = false
    @AppStorage(
        "widget.medium.backgroundColor", store: UserDefaults(suiteName: "group.com.cleansed.shared")
    )
    private var mediumBackgroundColor: String = "#1C1C1E"

    // Small
    @AppStorage(
        "widget.small.isLowercase", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallIsLowercase: Bool = false
    @AppStorage(
        "widget.small.fontSize", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallFontSize: Int = 18
    @AppStorage(
        "widget.small.alignment", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallAlignment: String = "leading"
    @AppStorage(
        "widget.small.horizontalPadding",
        store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallHorizontalPadding: Int = 8
    @AppStorage(
        "widget.small.verticalPadding", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallVerticalPadding: Int = 8
    @AppStorage(
        "widget.small.todosSpacing", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallTodosSpacing: Int = 5
    @AppStorage(
        "widget.small.useCustomBackground",
        store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallUseCustomBackground: Bool = false
    @AppStorage(
        "widget.small.backgroundColor", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    private var smallBackgroundColor: String = "#1C1C1E"

    init() {
        // Initialize selected color from Large settings as default
        // The actual color will be loaded in onAppear based on selectedFamily
        _selectedColor = State(initialValue: Color(hex: largeBackgroundColor) ?? .black)
    }

    var body: some View {
        List {
            // Preview Section
            Section {
                VStack {
                    Picker("Size", selection: $selectedFamily) {
                        Text("Small").tag(WidgetFamily.systemSmall)
                        Text("Medium").tag(WidgetFamily.systemMedium)
                        Text("Large").tag(WidgetFamily.systemLarge)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 10)
                    .onChange(of: selectedFamily) { _, _ in
                        updateSelectedColor()
                    }

                    WidgetPreviewView(family: selectedFamily)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
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
                    Toggle("", isOn: isLowercase)
                        .onChange(of: isLowercase.wrappedValue) { _, _ in
                            reloadWidgets()
                        }
                }

                // Font Size
                HStack {
                    Image(systemName: "textformat.size")
                        .frame(width: 30)
                    Text("Font size: \(fontSize.wrappedValue)")
                    Spacer()
                    Stepper("", value: fontSize, in: 8...40)
                        .onChange(of: fontSize.wrappedValue) { _, _ in
                            reloadWidgets()
                        }
                }

                // Alignment
                HStack {
                    Image(systemName: "text.alignleft")
                        .frame(width: 30)
                    Text("Alignment")
                    Spacer()
                    Picker("", selection: alignment) {
                        Text("Leading").tag("leading")
                        Text("Center").tag("center")
                        Text("Trailing").tag("trailing")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: alignment.wrappedValue) { _, _ in
                        reloadWidgets()
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
                    Text("Horizontal padding: \(horizontalPadding.wrappedValue)")
                    Spacer()
                    Stepper("", value: horizontalPadding, in: 0...50)
                        .onChange(of: horizontalPadding.wrappedValue) { _, _ in
                            reloadWidgets()
                        }
                }

                // Vertical Padding
                HStack {
                    Image(systemName: "arrow.up.and.down")
                        .frame(width: 30)
                    Text("Vertical padding: \(verticalPadding.wrappedValue)")
                    Spacer()
                    Stepper("", value: verticalPadding, in: 0...50)
                        .onChange(of: verticalPadding.wrappedValue) { _, _ in
                            reloadWidgets()
                        }
                }

                // Todos Spacing
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .frame(width: 30)
                    Text("Todos spacing: \(todosSpacing.wrappedValue)")
                    Spacer()
                    Stepper("", value: todosSpacing, in: 0...50)
                        .onChange(of: todosSpacing.wrappedValue) { _, _ in
                            reloadWidgets()
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
                    Toggle("", isOn: useCustomBackground)
                        .onChange(of: useCustomBackground.wrappedValue) { _, _ in
                            reloadWidgets()
                        }
                }

                // Color Picker
                if useCustomBackground.wrappedValue {
                    ColorPicker("Background Color", selection: $selectedColor)
                        .onChange(of: selectedColor) { _, newColor in
                            backgroundColor.wrappedValue = newColor.toHex()
                            reloadWidgets()
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
                        Text("Reset ALL defaults")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Widget Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateSelectedColor()
        }
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                settings.resetToDefaults()
                updateSelectedColor()
            }
        } message: {
            Text("Are you sure you want to reset all widget settings to default?")
        }
    }

    // MARK: - Bindings Helpers

    private var isLowercase: Binding<Bool> {
        switch selectedFamily {
        case .systemSmall: return $smallIsLowercase
        case .systemMedium: return $mediumIsLowercase
        default: return $largeIsLowercase
        }
    }

    private var fontSize: Binding<Int> {
        switch selectedFamily {
        case .systemSmall: return $smallFontSize
        case .systemMedium: return $mediumFontSize
        default: return $largeFontSize
        }
    }

    private var alignment: Binding<String> {
        switch selectedFamily {
        case .systemSmall: return $smallAlignment
        case .systemMedium: return $mediumAlignment
        default: return $largeAlignment
        }
    }

    private var horizontalPadding: Binding<Int> {
        switch selectedFamily {
        case .systemSmall: return $smallHorizontalPadding
        case .systemMedium: return $mediumHorizontalPadding
        default: return $largeHorizontalPadding
        }
    }

    private var verticalPadding: Binding<Int> {
        switch selectedFamily {
        case .systemSmall: return $smallVerticalPadding
        case .systemMedium: return $mediumVerticalPadding
        default: return $largeVerticalPadding
        }
    }

    private var todosSpacing: Binding<Int> {
        switch selectedFamily {
        case .systemSmall: return $smallTodosSpacing
        case .systemMedium: return $mediumTodosSpacing
        default: return $largeTodosSpacing
        }
    }

    private var useCustomBackground: Binding<Bool> {
        switch selectedFamily {
        case .systemSmall: return $smallUseCustomBackground
        case .systemMedium: return $mediumUseCustomBackground
        default: return $largeUseCustomBackground
        }
    }

    private var backgroundColor: Binding<String> {
        switch selectedFamily {
        case .systemSmall: return $smallBackgroundColor
        case .systemMedium: return $mediumBackgroundColor
        default: return $largeBackgroundColor
        }
    }

    // MARK: - Helpers

    private func reloadWidgets() {
        TodoManager.shared.reloadWidgets()
    }

    private func updateSelectedColor() {
        selectedColor = Color(hex: backgroundColor.wrappedValue) ?? .black
    }
}

#Preview {
    NavigationStack {
        WidgetSettingsView()
    }
}
