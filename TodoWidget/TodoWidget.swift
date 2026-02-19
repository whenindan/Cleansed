//
//  TodoWidget.swift
//  TodoWidget
//
//  Created by Nguyen Trong Dat on 2/17/26.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Timeline Entry
struct TodoEntry: TimelineEntry {
    let date: Date
    var todos: [TodoItemData]
}

// MARK: - Timeline Provider
struct TodoProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(
            date: Date(),
            todos: [
                TodoItemData(
                    id: UUID(), title: "Sample Todo", isCompleted: false, createdAt: Date(),
                    completedAt: nil, sortDate: Date()),
                TodoItemData(
                    id: UUID(), title: "Another Task", isCompleted: false, createdAt: Date(),
                    completedAt: nil, sortDate: Date()),
            ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        let todos = TodoManager.shared.getTodosFromUserDefaults()
        let entry = TodoEntry(date: Date(), todos: todos)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        let todos = TodoManager.shared.getTodosFromUserDefaults()
        let entry = TodoEntry(date: Date(), todos: todos)

        // Widget will be manually reloaded after actions, so use .never policy
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Widget Entry View
struct TodoWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TodoProvider.Entry

    let settings = WidgetSettings.shared

    var body: some View {
        VStack(alignment: currentAlignment, spacing: currentTodosSpacing) {
            // Todo items
            if entry.todos.isEmpty {
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    Text("All clear!")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                let displayTodos = Array(entry.todos.prefix(maxTodos))

                ForEach(displayTodos, id: \.id) { todo in
                    TodoRowView(todo: todo, family: family)
                }

                Spacer()
            }
        }
        .padding(.horizontal, currentHorizontalPadding)
        .padding(.vertical, currentVerticalPadding)
        .containerBackground(
            currentUseCustomBackground
                ? AnyShapeStyle(currentBackgroundColor)
                : AnyShapeStyle(.fill.tertiary),
            for: .widget
        )
        .widgetURL(URL(string: "cleansed://todos"))
    }

    // MARK: - Size-Specific Settings

    private var currentAlignment: HorizontalAlignment {
        switch family {
        case .systemSmall:
            return WidgetSettings.SmallWidgetSettings.alignment
        case .systemMedium:
            return WidgetSettings.MediumWidgetSettings.alignment
        default:  // .systemLarge
            return settings.textAlignment
        }
    }

    private var currentTodosSpacing: CGFloat {
        switch family {
        case .systemSmall:
            return WidgetSettings.SmallWidgetSettings.todosSpacing
        case .systemMedium:
            return WidgetSettings.MediumWidgetSettings.todosSpacing
        default:
            return CGFloat(settings.todosSpacing)
        }
    }

    private var currentHorizontalPadding: CGFloat {
        switch family {
        case .systemSmall:
            return WidgetSettings.SmallWidgetSettings.horizontalPadding
        case .systemMedium:
            return WidgetSettings.MediumWidgetSettings.horizontalPadding
        default:
            return CGFloat(settings.horizontalPadding)
        }
    }

    private var currentVerticalPadding: CGFloat {
        switch family {
        case .systemSmall:
            return WidgetSettings.SmallWidgetSettings.verticalPadding
        case .systemMedium:
            return WidgetSettings.MediumWidgetSettings.verticalPadding
        default:
            return CGFloat(settings.verticalPadding)
        }
    }

    private var currentUseCustomBackground: Bool {
        switch family {
        case .systemSmall:
            return WidgetSettings.SmallWidgetSettings.useCustomBackground
        case .systemMedium:
            return WidgetSettings.MediumWidgetSettings.useCustomBackground
        default:
            return settings.useCustomBackground
        }
    }

    private var currentBackgroundColor: Color {
        switch family {
        case .systemSmall:
            return Color(hex: WidgetSettings.SmallWidgetSettings.backgroundColor)
                ?? Color(UIColor.systemBackground)
        case .systemMedium:
            return Color(hex: WidgetSettings.MediumWidgetSettings.backgroundColor)
                ?? Color(UIColor.systemBackground)
        default:
            return settings.backgroundColorValue
        }
    }

    private var maxTodos: Int {
        switch family {
        case .systemSmall:
            return 3
        case .systemMedium:
            return 6
        case .systemLarge:
            return 12
        case .systemExtraLarge:
            return 20
        default:
            return 3
        }
    }
}

// MARK: - Todo Row View
struct TodoRowView: View {
    let todo: TodoItemData
    let family: WidgetFamily
    let settings = WidgetSettings.shared

    private var styledTitle: AttributedString {
        let title = currentIsLowercase ? todo.title.lowercased() : todo.title
        var attr = AttributedString(title)
        if todo.isCompleted {
            attr.strikethroughStyle = .single
            attr.foregroundColor = .secondary
        } else {
            attr.foregroundColor = .primary
        }
        return attr
    }

    private var currentIsLowercase: Bool {
        switch family {
        case .systemSmall:
            return WidgetSettings.SmallWidgetSettings.isLowercase
        case .systemMedium:
            return WidgetSettings.MediumWidgetSettings.isLowercase
        default:
            return settings.isLowercase
        }
    }

    private var currentFontSize: CGFloat {
        switch family {
        case .systemSmall:
            return CGFloat(WidgetSettings.SmallWidgetSettings.fontSize)
        case .systemMedium:
            return CGFloat(WidgetSettings.MediumWidgetSettings.fontSize)
        default:
            return CGFloat(settings.fontSize)
        }
    }

    var body: some View {
        Button(intent: ToggleTodoIntent(todoId: todo.id.uuidString)) {
            HStack {
                Text(styledTitle)
                    .font(.system(size: currentFontSize))
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Widget Configuration
struct TodoWidget: Widget {
    let kind: String = "TodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            TodoWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .configurationDisplayName("Todo List")
        .description("View and complete your todos from the home screen")
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    TodoWidget()
} timeline: {
    TodoEntry(
        date: .now,
        todos: [
            TodoItemData(
                id: UUID(), title: "Buy groceries", isCompleted: false, createdAt: Date(),
                completedAt: nil, sortDate: Date()),
            TodoItemData(
                id: UUID(), title: "Call mom", isCompleted: false, createdAt: Date(),
                completedAt: nil, sortDate: Date()),
            TodoItemData(
                id: UUID(), title: "Finish report", isCompleted: true, createdAt: Date(),
                completedAt: Date(), sortDate: Date()),
        ])
    TodoEntry(
        date: .now,
        todos: [
            TodoItemData(
                id: UUID(), title: "Morning workout", isCompleted: true, createdAt: Date(),
                completedAt: Date(), sortDate: Date()),
            TodoItemData(
                id: UUID(), title: "Team meeting", isCompleted: false, createdAt: Date(),
                completedAt: nil, sortDate: Date()),
        ])
}
