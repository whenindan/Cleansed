//
//  FocusGroup.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/23/26.
//

import Foundation
import SwiftData
import SwiftUI

/// The type of scheduling for a focus group
enum ScheduleType: String, Codable, CaseIterable {
    case manual = "Manual"
    case scheduled = "Scheduled"
    case timer = "Timer"

    var icon: String {
        switch self {
        case .manual: return "hand.tap"
        case .scheduled: return "calendar.badge.clock"
        case .timer: return "timer"
        }
    }

    var description: String {
        switch self {
        case .manual: return "Toggle on/off manually"
        case .scheduled: return "Repeating schedule"
        case .timer: return "Block for a set duration"
        }
    }
}

/// Preset timer durations in minutes
enum TimerDuration: Int, CaseIterable, Identifiable {
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case fourHours = 240
    case custom = -1

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .thirtyMinutes: return "30 min"
        case .oneHour: return "1 hour"
        case .twoHours: return "2 hours"
        case .fourHours: return "4 hours"
        case .custom: return "Custom"
        }
    }
}

@Model
final class FocusGroup {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isEnabled: Bool

    // Schedule configuration
    var scheduleTypeRaw: String
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var weekdays: [Int]  // 1=Sunday, 7=Saturday

    // Timer configuration
    var timerDuration: Int  // minutes
    var timerEndDate: Date?

    // App selection - encoded FamilyActivitySelection
    var selectedAppTokens: Data?

    var createdAt: Date

    var scheduleType: ScheduleType {
        get { ScheduleType(rawValue: scheduleTypeRaw) ?? .manual }
        set { scheduleTypeRaw = newValue.rawValue }
    }

    init(
        name: String = "New Focus",
        icon: String = "moon.fill",
        colorHex: String = "#5E5CE6",
        isEnabled: Bool = false,
        scheduleType: ScheduleType = .manual,
        startHour: Int = 22,
        startMinute: Int = 0,
        endHour: Int = 7,
        endMinute: Int = 0,
        weekdays: [Int] = [1, 2, 3, 4, 5, 6, 7],
        timerDuration: Int = 30,
        timerEndDate: Date? = nil,
        selectedAppTokens: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isEnabled = isEnabled
        self.scheduleTypeRaw = scheduleType.rawValue
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.weekdays = weekdays
        self.timerDuration = timerDuration
        self.timerEndDate = timerEndDate
        self.selectedAppTokens = selectedAppTokens
        self.createdAt = Date()
    }

    // MARK: - Helpers

    var color: Color {
        Color(hex: colorHex) ?? .purple
    }

    var scheduleDescription: String {
        switch scheduleType {
        case .manual:
            return isEnabled ? "Active" : "Tap to activate"
        case .scheduled:
            let start = String(format: "%d:%02d", startHour, startMinute)
            let end = String(format: "%d:%02d", endHour, endMinute)
            let days = weekdays.count == 7 ? "Every day" : weekdayLabels
            return "\(start) – \(end), \(days)"
        case .timer:
            if let endDate = timerEndDate, isEnabled {
                let remaining = endDate.timeIntervalSinceNow
                if remaining > 0 {
                    let mins = Int(remaining / 60)
                    return "\(mins) min remaining"
                } else {
                    return "Timer expired"
                }
            }
            return "\(timerDuration) min"
        }
    }

    private var weekdayLabels: String {
        let symbols = Calendar.current.shortWeekdaySymbols
        return weekdays.sorted().compactMap { day in
            guard day >= 1, day <= 7 else { return nil }
            return symbols[day - 1]
        }.joined(separator: ", ")
    }
}
