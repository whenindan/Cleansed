//
//  HabitWidget.swift
//  HabitWidget
//

import AppIntents
import SwiftUI
import WidgetKit

struct HabitProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        let dummyDates = generateDummyDates()
        return HabitEntry(
            date: Date(),
            habits: [
                HabitWidgetData(
                    id: UUID(), name: "Meditation", completedDates: dummyDates,
                    colorTheme: "#A154F2")
            ])
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        let habits = HabitWidgetManager.shared.getHabitsFromUserDefaults()
        let entry = HabitEntry(
            date: Date(), habits: habits.isEmpty ? placeholder(in: context).habits : habits)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let habits = HabitWidgetManager.shared.getHabitsFromUserDefaults()
        let entry = HabitEntry(date: Date(), habits: habits)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func generateDummyDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        for i in 0..<30 {
            if Bool.random() {
                if let d = calendar.date(byAdding: .day, value: -i, to: today) {
                    dates.append(d)
                }
            }
        }
        return dates
    }
}

struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [HabitWidgetData]
}

struct HabitWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: HabitProvider.Entry

    var body: some View {
        HabitWidgetContentView(family: family, entry: entry)
            .containerBackground(Color(hex: "#1C1C1E") ?? .black, for: .widget)
            .widgetURL(URL(string: "cleansed://habits"))
    }
}

// Widget Configuration
struct HabitWidget: Widget {
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitProvider()) { entry in
            HabitWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Habit Tracker")
        .description("Track your habits directly from the home screen.")
        .contentMarginsDisabled()
    }
}

// ContentView
struct HabitWidgetContentView: View {
    let family: WidgetFamily
    let entry: HabitEntry

    var body: some View {
        if entry.habits.isEmpty {
            VStack {
                Text("No Habits")
                    .foregroundColor(.secondary)
            }
        } else {
            // Display exactly one habit in small widget, maybe multiple in medium?
            // User design screenshot showed single habit for both small and medium.
            if let habit = entry.habits.first {
                HabitSingleView(habit: habit, family: family)
                    .padding(family == .systemSmall ? 14 : 18)
            }
        }
    }
}

struct HabitSingleView: View {
    let habit: HabitWidgetData
    let family: WidgetFamily

    var themeColor: Color {
        Color(hex: habit.colorTheme) ?? .green
    }

    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return habit.completedDates.contains { calendar.isDate($0, inSameDayAs: Date()) }
    }

    var rows: Int { 7 }
    var cols: Int { family == .systemSmall ? 10 : 22 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 8) {
                // Icon matching Mockup
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "flame.fill")  // placeholder icon
                        .font(.system(size: 16))
                        .foregroundColor(themeColor)
                }

                Text(habit.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                // Toggle Button
                Button(intent: ToggleHabitIntent(habitId: habit.id.uuidString)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isCompletedToday ? themeColor : Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)

                        if isCompletedToday {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)

            // Contribution Grid
            HabitContributionGrid(
                completedDates: habit.completedDates,
                themeColor: themeColor,
                rows: rows,
                cols: cols
            )

            if family == .systemSmall {
                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Text("HabitKit")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
            } else if family == .systemMedium {
                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Text("HabitKit")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
    }
}

struct HabitContributionGrid: View {
    let completedDates: [Date]
    let themeColor: Color
    let rows: Int
    let cols: Int

    var boolGrid: [[Bool]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var grid = Array(repeating: Array(repeating: false, count: cols), count: rows)

        let currentWeekday = calendar.component(.weekday, from: today)  // 1=Sun, 7=Sat
        let totalDays = cols * rows

        let completedSet = Set(completedDates.map { calendar.startOfDay(for: $0) })

        let daysOffsetToTopLeft = (cols - 1) * rows + (currentWeekday - 1)
        var currentDate = calendar.date(byAdding: .day, value: -daysOffsetToTopLeft, to: today)!

        for col in 0..<cols {
            for row in 0..<rows {
                if currentDate > today {
                    grid[row][col] = false
                } else {
                    grid[row][col] = completedSet.contains(currentDate)
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }

        return grid
    }

    var body: some View {
        let grid = boolGrid
        HStack(spacing: 3) {
            ForEach(0..<cols, id: \.self) { col in
                VStack(spacing: 3) {
                    ForEach(0..<rows, id: \.self) { row in
                        let isCompleted = grid[row][col]
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isCompleted ? themeColor : Color.white.opacity(0.12))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
}

// Minimal Color Ext for Hex
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
}
