//
//  TodoManager.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/17/26.
//

import Foundation
import SwiftData
import WidgetKit

/// Simplified todo data structure for widget communication
struct TodoItemData: Codable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let createdAt: Date
}

/// Manages synchronization between SwiftData and UserDefaults for widget access
class TodoManager {
    static let shared = TodoManager()

    private let sharedDefaults: UserDefaults
    private let todosKey = "todos"

    private init() {
        // Initialize with App Group - will be configured after adding capability
        sharedDefaults = UserDefaults(suiteName: "group.com.cleansed.shared")!
    }

    /// Sync todos from SwiftData to UserDefaults for widget access
    func syncTodosToUserDefaults(_ todos: [TodoItem]) {
        let todoData = todos.map { todo in
            TodoItemData(
                id: todo.id,
                title: todo.title,
                isCompleted: todo.isCompleted,
                createdAt: todo.createdAt
            )
        }

        if let encoded = try? JSONEncoder().encode(todoData) {
            sharedDefaults.set(encoded, forKey: todosKey)
            reloadWidgets()
        }
    }

    /// Get todos from UserDefaults (used by widget)
    func getTodosFromUserDefaults() -> [TodoItemData] {
        guard let data = sharedDefaults.data(forKey: todosKey),
            let todos = try? JSONDecoder().decode([TodoItemData].self, from: data)
        else {
            return []
        }
        return todos
    }

    /// Toggle todo completion status (called from widget intent)
    func toggleTodo(id: UUID) {
        var todos = getTodosFromUserDefaults()

        if let index = todos.firstIndex(where: { $0.id == id }) {
            let todo = todos[index]
            todos[index] = TodoItemData(
                id: todo.id,
                title: todo.title,
                isCompleted: !todo.isCompleted,
                createdAt: todo.createdAt
            )

            if let encoded = try? JSONEncoder().encode(todos) {
                sharedDefaults.set(encoded, forKey: todosKey)
                reloadWidgets()
            }
        }
    }

    /// Trigger widget timeline reload
    func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "TodoWidget")
    }
}
