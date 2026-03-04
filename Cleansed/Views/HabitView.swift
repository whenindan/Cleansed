//
//  HabitView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import SwiftData
import SwiftUI

struct HabitView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var auth: AuthManager
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var isAddSheetPresented = false
    @State private var newHabitName = ""
    @State private var newHabitStartDate = Date()
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    if habits.isEmpty {
                        ContentUnavailableView(
                            "No Habits",
                            systemImage: "chart.bar",
                            description: Text("Start building new habits today")
                        )
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(habits) { habit in
                                ZStack {
                                    HabitRowView(habit: habit)
                                        .contentShape(Rectangle())
                                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                                        Color.clear
                                    }
                                    .opacity(0)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(
                                    EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
                                )
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                )
                            }
                            .onDelete(perform: deleteHabits)
                        }
                        .hideListSeparators()
                    }
                }
                .background(Color(.systemBackground))

                FAB { isAddSheetPresented = true }
                    .padding(24)
            }
            .task {
                // Load account habits from Supabase on appear when signed in
                if auth.isAuthenticated, let userId = auth.currentUserId {
                    await DataSyncManager.shared.loadFromSupabase(
                        userId: userId, context: modelContext)
                }
            }
            .sheet(isPresented: $isAddSheetPresented) {
                NavigationStack {
                    Form {
                        Section {
                            TextField("Habit Name", text: $newHabitName)
                                .focused($isFocused)
                                .onSubmit { addHabit() }

                            DatePicker(
                                "Start Date",
                                selection: $newHabitStartDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                        }
                    }
                    .navigationTitle("New Habit")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isAddSheetPresented = false
                                newHabitName = ""
                                newHabitStartDate = Date()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") { addHabit() }
                                .disabled(
                                    newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        .isEmpty)
                        }
                    }
                    .onAppear { isFocused = true }
                }
                .presentationDetents([.height(240)])
            }
        }
    }

    // MARK: - Actions

    private func addHabit() {
        let trimmed = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newHabit = Habit(name: trimmed, startDate: newHabitStartDate)
        modelContext.insert(newHabit)
        try? modelContext.save()

        // Mirror to Supabase if signed in
        if auth.isAuthenticated, let userId = auth.currentUserId {
            Task {
                try? await SupabaseManager.shared.createHabitWithId(
                    id: newHabit.id, name: newHabit.name,
                    userId: userId, startDate: newHabit.startDate)
            }
        }

        newHabitName = ""
        newHabitStartDate = Date()
        isAddSheetPresented = false
    }

    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            if auth.isAuthenticated {
                Task { try? await SupabaseManager.shared.deleteHabit(id: habit.id) }
            }
            modelContext.delete(habit)
        }
        try? modelContext.save()
    }
}

#Preview {
    HabitView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
        .environmentObject(AuthManager())
}
