import SwiftData
import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header Stats
                VStack(spacing: 24) {
                    // Current Streak
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current streak")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(habit.calculateStreak()) days")
                                .font(.system(size: 42, weight: .medium, design: .default))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        if habit.calculateStreak() > 0 {
                            HStack(spacing: 4) {
                                Text("You're on fire")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }

                    // Best Streak
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Best streak")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(habit.calculateBestStreak()) days")
                                .font(.system(size: 42, weight: .medium, design: .default))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        if habit.calculateBestStreak() > 0 {
                            Text("Well done!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Completion Rate
                    HStack {
                        let completion = habit.completionRate()
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completion")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(completion.percent)%")
                                .font(.system(size: 42, weight: .medium, design: .default))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        Text("\(completion.count) of \(completion.total) days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // Calendar Grid
                VStack(alignment: .leading, spacing: 20) {
                    Text(Date().formatted(.dateTime.month(.wide).year()))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16
                    ) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Calendar Days
                        let daysInMonth = getDaysInCurrentMonth()
                        ForEach(daysInMonth, id: \.date) { day in
                            if day.day == 0 {
                                Color.clear
                                    .frame(height: 40)
                            } else {
                                CalendarDayCell(
                                    day: day.day,
                                    isCompleted: isDateCompleted(day.date),
                                    isToday: Calendar.current.isDateInToday(day.date)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Menu action placeholder
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Calendar Logic

    struct CalendarDay {
        let day: Int
        let date: Date
    }

    func getDaysInCurrentMonth() -> [CalendarDay] {
        let calendar = Calendar.current
        let today = Date()

        guard let range = calendar.range(of: .day, in: .month, for: today),
            let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: today))
        else {
            return []
        }

        // Calculate offset for the first day of the week (assuming Monday start like screenshot)
        //Weekday returns 1 for Sunday, 2 for Monday... so Monday(2) needs 0 offset.
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Convert to 0 (Mon) - 6 (Sun)
        // 1(Sun) -> 6
        // 2(Mon) -> 0
        let offset = (firstWeekday + 5) % 7

        var days: [CalendarDay] = []

        // Add empty placeholders
        for _ in 0..<offset {
            days.append(CalendarDay(day: 0, date: Date.distantPast))
        }

        // Add actual days
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(CalendarDay(day: day, date: date))
            }
        }

        return days
    }

    func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return habit.completions.contains { completion in
            calendar.isDate(completion.date, inSameDayAs: date)
        }
    }
}

struct CalendarDayCell: View {
    let day: Int
    let isCompleted: Bool
    let isToday: Bool

    var body: some View {
        ZStack {
            if isCompleted {
                Circle()
                    .fill(Color.white)
            } else if isToday {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            } else {
                Circle()
                    .fill(Color.clear)
            }

            Text("\(day)")
                .foregroundStyle(isCompleted ? Color.black : Color.white)
                .font(.system(size: 16, weight: .medium))
        }
        .frame(height: 40)
    }
}
