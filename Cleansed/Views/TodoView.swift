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
                        ForEach(todos) { todo in
                            Button {
                                todo.isCompleted.toggle()
                                try? modelContext.save()
                                TodoManager.shared.syncTodosToUserDefaults(todos)
                            } label: {
                                Text(todo.title)
                                    .font(.system(size: 18, weight: .regular, design: .default))
                                    .foregroundStyle(
                                        todo.isCompleted ? Color.secondary : Color.primary
                                    )
                                    .strikethrough(todo.isCompleted, color: Color.secondary)
                                    .animation(.default, value: todo.isCompleted)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
                        }
                        .onDelete(perform: deleteTodos)
                    }
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
                // Sync todos to UserDefaults for widget
                TodoManager.shared.syncTodosToUserDefaults(todos)

                // Sync changes from widget back to app
                syncFromWidget()
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
            modelContext.delete(todos[index])
        }
        try? modelContext.save()
    }

    private func syncFromWidget() {
        // Get todos from UserDefaults (updated by widget)
        let widgetTodos = TodoManager.shared.getTodosFromUserDefaults()

        // Update SwiftData todos to match widget changes
        for widgetTodo in widgetTodos {
            if let existingTodo = todos.first(where: { $0.id == widgetTodo.id }) {
                // Update completion status if it changed
                if existingTodo.isCompleted != widgetTodo.isCompleted {
                    existingTodo.isCompleted = widgetTodo.isCompleted
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
