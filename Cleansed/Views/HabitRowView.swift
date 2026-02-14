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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(habit.name)
                    .font(.headline)

                Spacer()

                // Current streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .imageScale(.small)
                    Text("\(habit.calculateStreak())")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            // 7-day visualization
            HStack(spacing: 8) {
                ForEach(last7Days, id: \.self) { date in
                    DaySquareView(
                        date: date,
                        isCompleted: isDateCompleted(date),
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                toggleCompletion(for: date)
                            }
                        }
                    )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct DaySquareView: View {
    let date: Date
    let isCompleted: Bool
    let onTap: () -> Void

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayLabel)
                .font(.caption2)
                .foregroundStyle(Color(.secondaryLabel))

            RoundedRectangle(cornerRadius: 6)
                .fill(isCompleted ? Color.accentColor : Color(.systemGray5))
                .frame(width: 32, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(.systemGray4), lineWidth: isCompleted ? 0 : 1)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .opacity(isCompleted ? 1 : 0)
                )
        }
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Habit.self, HabitCompletion.self, configurations: config)

    let habit = Habit(name: "Read")
    container.mainContext.insert(habit)

    // Add some sample completions
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

    let completion1 = HabitCompletion(date: today, habit: habit)
    let completion2 = HabitCompletion(date: yesterday, habit: habit)

    container.mainContext.insert(completion1)
    container.mainContext.insert(completion2)

    return List {
        HabitRowView(habit: habit)
    }
    .modelContainer(container)
}
