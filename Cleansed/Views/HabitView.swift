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
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var isAddSheetPresented = false
    @State private var newHabitName = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Title removed as requested

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
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    EmptyView()
                                }
                                .opacity(0)  // Invisible link that covers the row, but we want button tappable?
                                // Actually, separating row taps (days) vs row tap (navigate) is tricky.
                                // Best practice: Tap on text/empty space navigates. Tap on circles toggles.
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        }
                        .onDelete(perform: deleteHabits)
                    }
                    .hideListSeparators()
                }
            }
            .background(Color(.systemBackground))

            FAB {
                isAddSheetPresented = true
            }
            .padding(24)
        }
        .sheet(isPresented: $isAddSheetPresented) {
            NavigationStack {
                Form {
                    TextField("Habit Name", text: $newHabitName)
                        .focused($isFocused)
                        .onSubmit {
                            addHabit()
                        }
                }
                .navigationTitle("New Habit")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isAddSheetPresented = false
                            newHabitName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addHabit()
                        }
                        .disabled(
                            newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .onAppear {
                    isFocused = true
                }
            }
            .presentationDetents([.medium])
        }
    }

    private func addHabit() {
        let trimmedName = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newHabit = Habit(name: trimmedName)
        modelContext.insert(newHabit)
        try? modelContext.save()

        newHabitName = ""
        isAddSheetPresented = false
    }

    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(habits[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    HabitView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
