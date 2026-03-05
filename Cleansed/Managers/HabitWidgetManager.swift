//
//  HabitWidgetManager.swift
//  Cleansed
//

import Foundation
import SwiftData
import WidgetKit

/// Simplified habit data structure for widget
struct HabitWidgetData: Codable {
    let id: UUID
    let name: String
    let completedDates: [Date]
    let colorTheme: String
}

class HabitWidgetManager {
    static let shared = HabitWidgetManager()

    private let sharedDefaults: UserDefaults
    private let habitsKey = "habitsWidgetData"

    // Fun, vibrant colors matching the mockup
    private let colors = ["#A154F2", "#F2C035", "#35F28A", "#F26D85", "#5C99F2"]

    private init() {
        sharedDefaults = UserDefaults(suiteName: "group.com.cleansed.shared")!
    }

    private func getColor(for id: UUID) -> String {
        // Hash the UUID to deterministically pick a color
        let absHash = abs(id.hashValue)
        return colors[absHash % colors.count]
    }

    func syncHabitsToUserDefaults(_ habits: [Habit]) {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -120, to: Date()) ?? Date()

        let habitData = habits.map { habit in
            let validDates = habit.completions.map { $0.date }.filter { $0 >= cutoff }
            return HabitWidgetData(
                id: habit.id,
                name: habit.name,
                completedDates: validDates,
                colorTheme: getColor(for: habit.id)
            )
        }

        let sortedHabitData = habitData.sorted(by: { $0.name < $1.name })

        if let encoded = try? JSONEncoder().encode(sortedHabitData) {
            sharedDefaults.set(encoded, forKey: habitsKey)
            reloadWidgets()
        }
    }

    func getHabitsFromUserDefaults() -> [HabitWidgetData] {
        guard let data = sharedDefaults.data(forKey: habitsKey),
            let habits = try? JSONDecoder().decode([HabitWidgetData].self, from: data)
        else {
            return []
        }
        return habits
    }

    func toggleHabitCompletion(id: UUID, date: Date) {
        var habits = getHabitsFromUserDefaults()
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }

        let calendar = Calendar.current
        var dates = habits[index].completedDates

        if let existingIndex = dates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            dates.remove(at: existingIndex)  // Uncomplete
        } else {
            dates.append(date)  // Complete
        }

        habits[index] = HabitWidgetData(
            id: habits[index].id,
            name: habits[index].name,
            completedDates: dates,
            colorTheme: habits[index].colorTheme
        )

        if let encoded = try? JSONEncoder().encode(habits) {
            sharedDefaults.set(encoded, forKey: habitsKey)
            reloadWidgets()
        }
    }

    func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
}
