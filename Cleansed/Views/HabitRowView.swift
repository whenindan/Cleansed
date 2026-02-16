//
//  HabitRowView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import SwiftData
import SwiftUI

struct HabitRowView: View {
    @Environment(\.modelContext) private var modelContext
    let habit: Habit

    private var last7Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        return habit.completions.contains { completion in
            calendar.startOfDay(for: completion.date) == targetDay
        }
    }

    private func toggleCompletion(for date: Date) {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)

        // Check if already completed
        if let existingCompletion = habit.completions.first(where: { completion in
            calendar.startOfDay(for: completion.date) == targetDay
        }) {
            // Remove completion
            modelContext.delete(existingCompletion)
        } else {
            // Add completion
            let newCompletion = HabitCompletion(date: targetDay, habit: habit)
            modelContext.insert(newCompletion)
            habit.completions.append(newCompletion)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Name and Streak
            HStack {
                Text(habit.name)
                    .font(.title2)
                    .fontWeight(.medium)

                Spacer()

                Text("\(habit.calculateStreak()) day streak")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Bottom Row: Week Days
            HStack(spacing: 0) {
                ForEach(last7Days, id: \.self) { date in
                    DayCircleView(
                        date: date,
                        isCompleted: isDateCompleted(date),
                        state: getDayState(for: date),
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                toggleCompletion(for: date)
                            }
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
    }

    // Helper to determine day state
    private func getDayState(for date: Date) -> DayState {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return .today
        } else if date > Date() {
            return .future
        } else {
            return .past
        }
    }
}

enum DayState {
    case past, today, future
}

struct DayCircleView: View {
    let date: Date
    let isCompleted: Bool
    let state: DayState
    let onTap: () -> Void

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"  // M, T, W etc.
        return String(formatter.string(from: date).prefix(1))
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.primary : Color.clear)
                        .frame(width: 44, height: 44)  // Bigger circles as per design

                    Text(dayLabel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isCompleted ? Color(.systemBackground) : Color.primary)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(state == .future)  // Prevent tapping future dates?
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Habit.self, HabitCompletion.self, configurations: config)

    let habit = Habit(name: "Read")
    container.mainContext.insert(habit)

    return List {
        HabitRowView(habit: habit)
    }
    .modelContainer(container)
}
