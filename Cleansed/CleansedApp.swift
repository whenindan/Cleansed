//
//  CleansedApp.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import SwiftData
import SwiftUI

@main
struct CleansedApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [TodoItem.self, Habit.self, HabitCompletion.self, FocusSchedule.self])
        { result in
            do {
                let container = try result.get()
                // Configure automatic migration
                container.mainContext.autosaveEnabled = true
            } catch {
                print("Failed to configure model container: \(error)")
            }
        }
    }
}
