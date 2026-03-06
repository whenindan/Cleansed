import SwiftData
import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var auth: AuthManager
    @State private var selectedMonth: Date = Date()
    @State private var editedColorHex: String = "#A154F2"
    @State private var editedIconName: String = "flame.fill"
    @State private var isCustomizingAppearance: Bool = false
    @State private var iconSearchText: String = ""
    @State private var selectedColor: Color = .purple

    // TEST MODE: Set to true to enable calendar editing for testing
    private let enableCalendarEditing = true

    private let colors: [(String, String)] = [
        ("#A154F2", "Purple"),
        ("#5C99F2", "Blue"),
        ("#35F28A", "Green"),
        ("#F2C035", "Yellow"),
        ("#F26D85", "Red"),
        ("#5E5CE6", "Indigo"),
        ("#FFB347", "Orange"),
        ("#14B8A6", "Teal"),
        ("#EC4899", "Pink"),
        ("#F59E0B", "Amber"),
    ]

    private let icons = [
        "flame.fill", "moon.fill", "sun.max.fill", "book.fill",
        "heart.fill", "bolt.fill", "leaf.fill", "star.fill",
        "figure.walk", "music.note", "paintbrush.fill", "drop.fill",
        "pencil", "dumbbell.fill", "brain.head.profile", "bed.double.fill",
        "airplane", "car.fill", "bicycle", "tram.fill",
        "cart.fill", "bag.fill", "creditcard.fill", "banknote.fill",
        "cross.case.fill", "pills.fill", "stethoscope", "syringe.fill",
        "cup.and.saucer.fill", "wineglass.fill", "fork.knife", "takeoutbag.and.cup.and.straw.fill",
        "gamecontroller.fill", "tv.fill", "headphones", "pianokeys",
        "pawprint.fill", "tortoise.fill", "ladybug.fill", "ant.fill",
        "house.fill", "building.2.fill", "tent.fill", "tree.fill",
        "graduationcap.fill", "briefcase.fill", "display", "laptopcomputer",
        "hammer.fill", "wrench.and.screwdriver.fill", "gearshape.fill", "scissors",
        "magnifyingglass", "lightbulb.fill", "camera.fill", "video.fill",
        "mic.fill", "message.fill", "phone.fill", "envelope.fill",
        "mappin.and.ellipse", "map.fill", "clock.fill", "alarm.fill",
        "timer", "stopwatch.fill", "calendar", "list.bullet",
        "checklist", "rosette", "trophy.fill", "medal.fill",
        "gift.fill", "balloon.2.fill", "party.popper.fill", "sparkles",
        "smiley.fill", "hand.thumbsup.fill", "figure.run", "figure.yoga",
        "water.waves", "flame", "drop", "cloud.rain.fill",
    ]

    private var filteredIcons: [String] {
        if iconSearchText.isEmpty {
            return icons
        } else {
            return icons.filter { $0.localizedCaseInsensitiveContains(iconSearchText) }
        }
    }

    private var accentColor: Color {
        Color(hex: editedColorHex) ?? .purple
    }

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
                                .foregroundStyle(Color.primary)
                        }

                        Spacer()
                    }

                    // Best Streak
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Best streak")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(habit.calculateBestStreak()) days")
                                .font(.system(size: 42, weight: .medium, design: .default))
                                .foregroundStyle(Color.primary)
                        }

                        Spacer()
                    }

                    // Completion Rate
                    HStack(alignment: .top) {
                        let completion = habit.completionRate()
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Completion")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text("\(completion.count) of \(completion.total) days")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Text("\(completion.percent)%")
                                .font(.system(size: 42, weight: .medium, design: .default))
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
                .padding(.horizontal)

                // Widget Appearance
                widgetAppearanceSection

                // Calendar Grid
                VStack(alignment: .leading, spacing: 20) {
                    // Month navigation
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16
                    ) {
                        // Day labels with unique IDs
                        ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                            Text(day)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Calendar Days
                        let daysInMonth = getDaysInMonth(for: selectedMonth)
                        ForEach(daysInMonth) { day in
                            if day.day == 0 {
                                Color.clear
                                    .frame(height: 40)
                            } else {
                                CalendarDayCell(
                                    day: day.day,
                                    isCompleted: isDateCompleted(day.date),
                                    isToday: Calendar.current.isDateInToday(day.date),
                                    onTap: enableCalendarEditing
                                        ? {
                                            toggleCompletion(for: day.date)
                                        } : nil
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
        .onAppear {
            editedColorHex = habit.colorHex.isEmpty ? "#A154F2" : habit.colorHex
            editedIconName = habit.iconName.isEmpty ? "flame.fill" : habit.iconName
            selectedColor = Color(hex: editedColorHex) ?? .purple
        }
        .onChange(of: selectedColor) { _, newValue in
            editedColorHex = newValue.toHex()
            saveAppearance()
        }
    }

    // MARK: - Widget Appearance Section

    private var widgetAppearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with live preview
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: editedIconName)
                        .font(.system(size: 20))
                        .foregroundColor(accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Widget Appearance")
                        .font(.headline)
                    Text("Customize the icon and color on your widget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Button {
                    withAnimation {
                        isCustomizingAppearance.toggle()
                    }
                } label: {
                    Text(isCustomizingAppearance ? "Done" : "Customize")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(accentColor)
                        .cornerRadius(12)
                }
            }

            if isCustomizingAppearance {
                // Color Picker
                ColorPicker("Color", selection: $selectedColor, supportsOpacity: false)
                    .font(.subheadline)
                    .padding(.vertical, 8)

                // Icon Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Icon")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search icons...", text: $iconSearchText)
                            .disableAutocorrection(true)

                        if !iconSearchText.isEmpty {
                            Button {
                                iconSearchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                    ScrollView {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12
                        ) {
                            ForEach(filteredIcons, id: \.self) { icon in
                                let isSelected = editedIconName == icon
                                Button {
                                    editedIconName = icon
                                    saveAppearance()
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title3)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    isSelected
                                                        ? accentColor.opacity(0.2)
                                                        : Color(.secondarySystemBackground))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    isSelected ? accentColor : .clear, lineWidth: 2)
                                        )
                                        .foregroundColor(isSelected ? accentColor : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 200)  // Scrollable constrained area
                }
            }
        }
        .padding(.horizontal)
    }

    private func saveAppearance() {
        habit.colorHex = editedColorHex
        habit.iconName = editedIconName
        try? modelContext.save()
        HabitWidgetManager.shared.updateHabitAppearance(
            id: habit.id, colorHex: editedColorHex, iconName: editedIconName)
    }

    // MARK: - Calendar Logic

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    private func previousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }

    private func nextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newMonth
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
            if auth.isAuthenticated {
                Task {
                    try? await SupabaseManager.shared.removeCompletion(
                        habitId: habit.id, date: targetDay)
                }
            }
        } else {
            // Add completion
            let newCompletion = HabitCompletion(date: targetDay, habit: habit)
            modelContext.insert(newCompletion)
            habit.completions.append(newCompletion)
            if auth.isAuthenticated, let userId = auth.currentUserId {
                Task {
                    try? await SupabaseManager.shared.logCompletionWithId(
                        id: newCompletion.id,
                        habitId: habit.id,
                        userId: userId,
                        date: targetDay
                    )
                }
            }
        }

        try? modelContext.save()
    }

    struct CalendarDay: Identifiable {
        let id: UUID = UUID()
        let day: Int
        let date: Date
    }

    func getDaysInMonth(for month: Date) -> [CalendarDay] {
        let calendar = Calendar.current

        guard let range = calendar.range(of: .day, in: .month, for: month),
            let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: month))
        else {
            return []
        }

        // Calculate offset for the first day of the week (assuming Monday start)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Convert to 0 (Mon) - 6 (Sun)
        // 1(Sun) -> 6
        // 2(Mon) -> 0
        let offset = (firstWeekday + 5) % 7

        var days: [CalendarDay] = []

        // Add empty placeholders with unique IDs
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
    let onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            if let onTap = onTap {
                withAnimation(.spring(response: 0.3)) {
                    onTap()
                }
            }
        }) {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(Color.primary)
                } else if isToday {
                    Circle()
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                } else {
                    Circle()
                        .fill(Color.clear)
                }

                Text("\(day)")
                    .foregroundStyle(isCompleted ? Color(.systemBackground) : Color.primary)
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }
}
