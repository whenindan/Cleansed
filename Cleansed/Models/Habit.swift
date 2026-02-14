//
//  Habit.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }

    // Helper to get completions for the last 7 days
    func getLast7DaysCompletions() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let last7Days = (0..<7).compactMap { offset -> Date? in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }

        let completedDates = completions.map { calendar.startOfDay(for: $0.date) }
        return last7Days.filter { completedDates.contains($0) }
    }

    // Calculate current streak
    func calculateStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let completedDates = Set(completions.map { calendar.startOfDay(for: $0.date) })

        var streak = 0
        var currentDate = today

        while completedDates.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }

        return streak
    }
}
