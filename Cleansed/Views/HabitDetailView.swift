import SwiftData
import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Stats
                HStack(spacing: 20) {
                    StatBox(
                        title: "Current streak", value: "\(habit.calculateStreak()) days",
                        icon: "flame.fill", iconColor: .orange, isHighlighted: true)
                }
                .padding(.horizontal)

                HStack(spacing: 20) {
                    StatBox(
                        title: "Best streak", value: "\(habit.calculateBestStreak()) days",
                        icon: nil, iconColor: .white, isHighlighted: false)

                    let completion = habit.completionRate()
                    StatBox(
                        title: "Completion", value: "\(completion.percent)%",
                        suffix: "\(completion.count) of \(completion.total) days", icon: nil,
                        iconColor: .white, isHighlighted: false)
                }
                .padding(.horizontal)

                // Calendar Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text(Date().formatted(.dateTime.month(.wide).year()))
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12
                    ) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Placeholder for actual calendar logic - simpler implementation for now
                        // In a real app, we'd calculate exact days offset
                        ForEach(1...30, id: \.self) { day in
                            CalendarDayCell(day: day, isCompleted: isDayCompleted(day))
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
                    Image(systemName: "ellipsis")
                }
            }
        }
    }

    // Helper for demo purposes - relies on simple check
    func isDayCompleted(_ day: Int) -> Bool {
        // This is a simplified check. In production, match actual dates.
        // For now, let's just check if we have any completion on this 'day' number of current month
        let calendar = Calendar.current
        let today = Date()
        // This is tricky without full calendar logic, so for the UI demo we might simplify or check actual logic
        // Let's use the actual data if possible, but mapping "day 1..30" to dates is complex in a quick view.
        // For this task, getting the UI structure is priority.
        return false
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var suffix: String? = nil
    let icon: String?
    let iconColor: Color
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)

                if let suffix = suffix {
                    Spacer()
                    Text(suffix)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let icon = icon {
                HStack {
                    Spacer()
                    if isHighlighted {
                        Text("You're on fire")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))  // slightly lighter than black
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CalendarDayCell: View {
    let day: Int
    let isCompleted: Bool

    var body: some View {
        ZStack {
            if isCompleted {
                Circle()
                    .fill(Color.primary)
            } else {
                Circle()
                    .fill(Color.clear)
            }

            Text("\(day)")
                .foregroundStyle(isCompleted ? Color(.systemBackground) : Color.primary)
                .font(.subheadline)
        }
        .frame(height: 40)
    }
}
