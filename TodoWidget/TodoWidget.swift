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
                    id: UUID(), title: "Sample Todo", isCompleted: false, createdAt: Date()),
                TodoItemData(
                    id: UUID(), title: "Another Task", isCompleted: false, createdAt: Date()),
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

// MARK: - Widget View
struct TodoWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TodoProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                    TodoRowView(todo: todo)
                }

                Spacer()
            }
        }
        .padding(12)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "cleansed://todos"))
    }

    private var maxTodos: Int {
        switch family {
        case .systemSmall:
            return 3
        case .systemMedium:
            return 6
        default:
            return 3
        }
    }
}

// MARK: - Todo Row View
struct TodoRowView: View {
    let todo: TodoItemData

    private var styledTitle: AttributedString {
        var attr = AttributedString(todo.title)
        if todo.isCompleted {
            attr.strikethroughStyle = .single
            attr.foregroundColor = .secondary
        } else {
            attr.foregroundColor = .primary
        }
        return attr
    }

    var body: some View {
        Button(intent: ToggleTodoIntent(todoId: todo.id.uuidString)) {
            HStack {
                Text(styledTitle)
                    .font(.system(size: 13))
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
        .supportedFamilies([.systemSmall, .systemMedium])
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
            TodoItemData(id: UUID(), title: "Buy groceries", isCompleted: false, createdAt: Date()),
            TodoItemData(id: UUID(), title: "Call mom", isCompleted: false, createdAt: Date()),
            TodoItemData(id: UUID(), title: "Finish report", isCompleted: true, createdAt: Date()),
        ])
    TodoEntry(
        date: .now,
        todos: [
            TodoItemData(
                id: UUID(), title: "Morning workout", isCompleted: true, createdAt: Date()),
            TodoItemData(id: UUID(), title: "Team meeting", isCompleted: false, createdAt: Date()),
        ])
}
