//
//  TodoView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import SwiftData
import SwiftUI

struct TodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var todos: [TodoItem]

    /// Incomplete first (Oldest sortDate -> Newest), then Completed (Most recently completed -> Oldest).
    /// - New items appear at the BOTTOM of Incomplete list (near action area).
    /// - Unchecked items appear at the BOTTOM of Incomplete list (near where they were clicked).
    /// - Completed items appear at the TOP of Completed list (near where they were clicked).
    private var sortedTodos: [TodoItem] {
        todos.sorted {
            if $0.isCompleted != $1.isCompleted { return !$0.isCompleted }

            if $0.isCompleted {
                // Completed: Most recently completed at the top
                let d0 = $0.completedAt ?? $0.createdAt
                let d1 = $1.completedAt ?? $1.createdAt
                return d0 > d1
            } else {
                // Incomplete: Oldest sortDate first (New items at bottom)
                return $0.sortDate < $1.sortDate
            }
        }
    }

    @State private var isAddSheetPresented = false
    @State private var newTodoTitle = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Title removed as requested

                if todos.isEmpty {
                    ContentUnavailableView(
                        "All clear",
                        systemImage: "checkmark.circle",
                        description: Text("Tap + to add a task")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(sortedTodos) { todo in
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    todo.isCompleted.toggle()
                                    if todo.isCompleted {
                                        todo.completedAt = Date()
                                    } else {
                                        todo.completedAt = nil
                                        todo.sortDate = Date()  // Move to bottom of incomplete list
                                    }
                                    try? modelContext.save()
                                    TodoManager.shared.syncTodosToUserDefaults(todos)
                                }
                            } label: {
                                Text(todo.title)
                                    .font(.system(size: 18, weight: .regular, design: .default))
                                    .foregroundStyle(
                                        todo.isCompleted ? Color.secondary : Color.primary
                                    )
                                    .strikethrough(todo.isCompleted, color: Color.secondary)
                                    .animation(.easeInOut(duration: 0.2), value: todo.isCompleted)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
                        }
                        .onDelete(perform: deleteTodos)
                        .onMove { from, to in
                            // no-op: list handles visual move, real order is driven by sort
                        }
                    }
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.75), value: sortedTodos.map(\.id)
                    )
                    .padding(.top, 24)
                    .hideListSeparators()
                }
            }
            .background(Color(.systemBackground))
            .onChange(of: todos) { _, newTodos in
                // Sync todos to UserDefaults for widget access
                TodoManager.shared.syncTodosToUserDefaults(newTodos)
            }
            .onAppear {
                // Sync changes from widget back to app
                syncFromWidget()

                // Sync todos to UserDefaults for widget
                TodoManager.shared.syncTodosToUserDefaults(todos)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    // Sync widget changes back to app when returning to foreground
                    syncFromWidget()
                }
            }

            // FAB
            FAB {
                isAddSheetPresented = true
            }
            .padding(24)
        }
        .sheet(isPresented: $isAddSheetPresented) {
            NavigationStack {
                Form {
                    TextField("New Task", text: $newTodoTitle)
                        .focused($isFocused)
                        .onSubmit {
                            addTodo()
                        }
                }
                .navigationTitle("New Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isAddSheetPresented = false
                            newTodoTitle = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addTodo()
                        }
                        .disabled(
                            newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .onAppear {
                    isFocused = true
                }
            }
            .presentationDetents([.height(180)])
        }
    }

    private func addTodo() {
        let trimmedTitle = newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let newTodo = TodoItem(title: trimmedTitle)
        // sortDate defaults to Date(), putting it at the bottom
        modelContext.insert(newTodo)

        do {
            try modelContext.save()
            newTodoTitle = ""
            isAddSheetPresented = false
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    private func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedTodos[index])
        }
        try? modelContext.save()
    }

    private func syncFromWidget() {
        // Get todos from UserDefaults (updated by widget)
        let widgetTodos = TodoManager.shared.getTodosFromUserDefaults()

        // Update SwiftData todos to match widget changes
        for widgetTodo in widgetTodos {
            if let existingTodo = todos.first(where: { $0.id == widgetTodo.id }) {
                // Update properties if they changed
                if existingTodo.isCompleted != widgetTodo.isCompleted {
                    existingTodo.isCompleted = widgetTodo.isCompleted
                    existingTodo.completedAt = widgetTodo.completedAt
                    // Also sync sortDate if available (though Widget effectively sets it to Date() on uncheck)
                    existingTodo.sortDate = widgetTodo.sortDate
                }
            }
        }

        try? modelContext.save()
    }
}

#Preview {
    TodoView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
