//
//  SelectHabitIntent.swift
//  HabitWidget
//

import AppIntents
import WidgetKit

// MARK: - Color Enum

@available(iOS 17.0, *)
enum HabitWidgetColor: String, AppEnum {
    case purple = "#A154F2"
    case blue = "#5C99F2"
    case green = "#35F28A"
    case yellow = "#F2C035"
    case red = "#F26D85"
    case indigo = "#5E5CE6"
    case orange = "#FFB347"
    case teal = "#14B8A6"
    case pink = "#EC4899"
    case amber = "#F59E0B"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Color"
    static var caseDisplayRepresentations: [HabitWidgetColor: DisplayRepresentation] = [
        .purple: "Purple",
        .blue: "Blue",
        .green: "Green",
        .yellow: "Yellow",
        .red: "Red",
        .indigo: "Indigo",
        .orange: "Orange",
        .teal: "Teal",
        .pink: "Pink",
        .amber: "Amber",
    ]
}

// MARK: - Icon Enum

@available(iOS 17.0, *)
enum HabitWidgetIcon: String, AppEnum {
    case flame = "flame.fill"
    case moon = "moon.fill"
    case sun = "sun.max.fill"
    case book = "book.fill"
    case heart = "heart.fill"
    case bolt = "bolt.fill"
    case leaf = "leaf.fill"
    case star = "star.fill"
    case figure = "figure.walk"
    case music = "music.note"
    case paintbrush = "paintbrush.fill"
    case drop = "drop.fill"
    case pencil = "pencil"
    case dumbbell = "dumbbell.fill"
    case brain = "brain.head.profile"
    case bed = "bed.double.fill"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Icon"
    static var caseDisplayRepresentations: [HabitWidgetIcon: DisplayRepresentation] = [
        .flame: "Flame",
        .moon: "Moon",
        .sun: "Sun",
        .book: "Book",
        .heart: "Heart",
        .bolt: "Lightning",
        .leaf: "Leaf",
        .star: "Star",
        .figure: "Walking",
        .music: "Music",
        .paintbrush: "Paintbrush",
        .drop: "Drop",
        .pencil: "Pencil",
        .dumbbell: "Dumbbell",
        .brain: "Brain",
        .bed: "Sleep",
    ]
}

// MARK: - Intent

@available(iOS 17.0, *)
struct SelectHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    static var description = IntentDescription("Select which habit this widget should display.")

    @Parameter(title: "Habit")
    var habit: HabitEntity?

    @Parameter(title: "Color", default: .purple)
    var color: HabitWidgetColor

    @Parameter(title: "Icon", default: .flame)
    var icon: HabitWidgetIcon

    init(habit: HabitEntity, color: HabitWidgetColor = .purple, icon: HabitWidgetIcon = .flame) {
        self.habit = habit
        self.color = color
        self.icon = icon
    }

    init() {
        self.color = .purple
        self.icon = .flame
    }
}
