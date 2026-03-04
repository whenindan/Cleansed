//
//  DataSyncManager.swift
//  Cleansed
//

import Foundation
import SwiftData

/// Coordinates syncing todos and habits between Supabase (cloud) and SwiftData (local mirror).
@MainActor
class DataSyncManager: ObservableObject {
    static let shared = DataSyncManager()
    private init() {}

    // MARK: - Load from Supabase into SwiftData (called on sign-in)

    func loadFromSupabase(userId: UUID, context: ModelContext) async {
        await loadTodos(userId: userId, context: context)
        await loadHabits(userId: userId, context: context)
    }

    // MARK: - Migrate guest data to Supabase (called when guest signs up / logs in)

    func migrateGuestData(
        userId: UUID,
        localTodos: [TodoItem],
        localHabits: [Habit],
        context: ModelContext
    ) async {
        await migrateTodos(userId: userId, localTodos: localTodos)
        await migrateHabits(userId: userId, localHabits: localHabits)
        // After migration, reload from Supabase to sync IDs
        await loadFromSupabase(userId: userId, context: context)
    }

    // MARK: - Clear local data on sign-out

    func clearLocalData(context: ModelContext) {
        // IMPORTANT: context.delete(model:) is a batch delete that bypasses
        // SwiftData cascade rules, causing constraint violations when
        // HabitCompletion has a mandatory relationship back to Habit.
        // Always fetch-and-delete individually, completions first.
        do {
            let completions = try context.fetch(FetchDescriptor<HabitCompletion>())
            for c in completions { context.delete(c) }

            let habits = try context.fetch(FetchDescriptor<Habit>())
            for h in habits { context.delete(h) }

            let todos = try context.fetch(FetchDescriptor<TodoItem>())
            for t in todos { context.delete(t) }

            try context.save()
        } catch {
            print("DataSyncManager: failed to clear local data: \(error)")
        }
    }

    // MARK: - Private: Todos

    private func loadTodos(userId: UUID, context: ModelContext) async {
        do {
            let remoteTodos = try await SupabaseManager.shared.fetchTodos(userId: userId)

            // Delete existing todos individually (batch delete bypasses validation)
            let existing = try context.fetch(FetchDescriptor<TodoItem>())
            for item in existing { context.delete(item) }
            try context.save()

            // Insert fresh from Supabase
            for record in remoteTodos {
                let item = TodoItem(title: record.title, isCompleted: record.isCompleted)
                item.id = record.id
                if let completedAt = record.completedAt { item.completedAt = completedAt }
                if let sortDate = record.sortDate { item.sortDate = sortDate }
                if let createdAt = record.createdAt { item.createdAt = createdAt }
                context.insert(item)
            }
            try context.save()
        } catch {
            print("DataSyncManager: failed to load todos: \(error)")
        }
    }

    private func migrateTodos(userId: UUID, localTodos: [TodoItem]) async {
        for todo in localTodos {
            do {
                _ = try await SupabaseManager.shared.createTodoWithId(
                    id: todo.id,
                    title: todo.title,
                    isCompleted: todo.isCompleted,
                    completedAt: todo.completedAt,
                    sortDate: todo.sortDate,
                    userId: userId
                )
            } catch {
                print("DataSyncManager: failed to migrate todo '\(todo.title)': \(error)")
            }
        }
    }

    // MARK: - Private: Habits

    private func loadHabits(userId: UUID, context: ModelContext) async {
        do {
            let remoteHabits = try await SupabaseManager.shared.fetchHabits(userId: userId)

            // Always delete completions before habits — mandatory relationship constraint
            let existingCompletions = try context.fetch(FetchDescriptor<HabitCompletion>())
            for c in existingCompletions { context.delete(c) }

            let existingHabits = try context.fetch(FetchDescriptor<Habit>())
            for h in existingHabits { context.delete(h) }

            try context.save()

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            for record in remoteHabits {
                let startDate = formatter.date(from: record.startDate) ?? Date()
                let habit = Habit(name: record.name, startDate: startDate)
                habit.id = record.id
                if let createdAt = record.createdAt { habit.createdAt = createdAt }
                context.insert(habit)

                // Load completions for this habit
                let completions = try await SupabaseManager.shared.fetchCompletions(
                    habitId: record.id)
                for comp in completions {
                    let completionDate = formatter.date(from: comp.completedDate) ?? Date()
                    let hc = HabitCompletion(date: completionDate, habit: habit)
                    hc.id = comp.id
                    context.insert(hc)
                }
            }
            try context.save()
        } catch {
            print("DataSyncManager: failed to load habits: \(error)")
        }
    }

    private func migrateHabits(userId: UUID, localHabits: [Habit]) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for habit in localHabits {
            do {
                _ = try await SupabaseManager.shared.createHabitWithId(
                    id: habit.id,
                    name: habit.name,
                    userId: userId,
                    startDate: habit.startDate
                )
                for completion in habit.completions {
                    try await SupabaseManager.shared.logCompletionWithId(
                        id: completion.id,
                        habitId: habit.id,
                        userId: userId,
                        date: completion.date
                    )
                }
            } catch {
                print("DataSyncManager: failed to migrate habit '\(habit.name)': \(error)")
            }
        }
    }
}
