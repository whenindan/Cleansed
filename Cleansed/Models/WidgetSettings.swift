//
//  WidgetSettings.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/17/26.
//

import SwiftUI
import WidgetKit

/// Widget customization settings shared between app and widget
class WidgetSettings {
    static let shared = WidgetSettings()

    private let defaults: UserDefaults

    private init() {
        defaults = UserDefaults(suiteName: "group.com.cleansed.shared")!
    }

    // MARK: - Settings Properties (Only for Large Widget)

    @AppStorage("widget.isLowercase", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var isLowercase: Bool = false

    @AppStorage("widget.fontSize", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var fontSize: Int = 13

    @AppStorage("widget.alignment", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var alignment: String = "leading"

    @AppStorage(
        "widget.horizontalPadding", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var horizontalPadding: Int = 12

    @AppStorage(
        "widget.verticalPadding", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var verticalPadding: Int = 8

    @AppStorage("widget.todosSpacing", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var todosSpacing: Int = 8

    @AppStorage(
        "widget.useCustomBackground", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var useCustomBackground: Bool = false

    @AppStorage(
        "widget.backgroundColor", store: UserDefaults(suiteName: "group.com.cleansed.shared"))
    var backgroundColor: String = "#1C1C1E"

    // MARK: - Size-Specific Settings (Hardcoded for Manual Testing)

    /// Small widget settings - CUSTOMIZE THESE VALUES
    struct SmallWidgetSettings {
        static let isLowercase = false
        static let fontSize = 12
        static let alignment: HorizontalAlignment = .leading
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 8
        static let todosSpacing: CGFloat = 6
        static let useCustomBackground = false
        static let backgroundColor = "#1C1C1E"
    }

    /// Medium (horizontal) widget settings - CUSTOMIZE THESE VALUES
    struct MediumWidgetSettings {
        static let isLowercase = false
        static let fontSize = 13
        static let alignment: HorizontalAlignment = .leading
        static let horizontalPadding: CGFloat = 14
        static let verticalPadding: CGFloat = 10
        static let todosSpacing: CGFloat = 8
        static let useCustomBackground = false
        static let backgroundColor = "#1C1C1E"
    }

    /// Large widget settings - Uses customizable settings from Account tab
    var largeWidgetSettings:
        (
            isLowercase: Bool,
            fontSize: Int,
            alignment: HorizontalAlignment,
            horizontalPadding: CGFloat,
            verticalPadding: CGFloat,
            todosSpacing: CGFloat,
            useCustomBackground: Bool,
            backgroundColor: Color
        )
    {
        return (
            isLowercase: isLowercase,
            fontSize: fontSize,
            alignment: textAlignment,
            horizontalPadding: CGFloat(horizontalPadding),
            verticalPadding: CGFloat(verticalPadding),
            todosSpacing: CGFloat(todosSpacing),
            useCustomBackground: useCustomBackground,
            backgroundColor: backgroundColorValue
        )
    }

    // MARK: - Computed Properties

    var textAlignment: HorizontalAlignment {
        switch alignment {
        case "center": return .center
        case "trailing": return .trailing
        default: return .leading
        }
    }

    var backgroundColorValue: Color {
        Color(hex: backgroundColor) ?? Color(UIColor.systemBackground)
    }

    // MARK: - Methods

    func resetToDefaults() {
        isLowercase = false
        fontSize = 13
        alignment = "leading"
        horizontalPadding = 12
        verticalPadding = 8
        todosSpacing = 8
        useCustomBackground = false
        backgroundColor = "#1C1C1E"

        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
