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
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var todos: [TodoItem]

    @State private var isAddSheetPresented = false
    @State private var newTodoTitle = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Custom Header "Inbox"
                Text("Inbox")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

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
                            Toggle(isOn: Bindable(todo).isCompleted) {
                                Text(todo.title)
                                    .font(.body)
                            }
                            .toggleStyle(MinimalistCheckboxStyle())
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))  // Padding for rows
                        }
                        .onDelete(perform: deleteTodos)
                    }
                    .hideListSeparators()
                }
            }
            .background(Color(.systemBackground))

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
            .presentationDetents([.medium])
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
}

#Preview {
    TodoView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
