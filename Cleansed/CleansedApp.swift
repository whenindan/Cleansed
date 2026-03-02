//
//  CleansedApp.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import FamilyControls
import SwiftData
import SwiftUI

@main
struct CleansedApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                } else {
                    SignInView()
                }
            }
            .environmentObject(authManager)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onOpenURL { url in
                Task { await authManager.handleDeepLink(url) }
            }
        }
        .modelContainer(for: [TodoItem.self, Habit.self, HabitCompletion.self, FocusGroup.self]) {
            result in
            do {
                let container = try result.get()
                container.mainContext.autosaveEnabled = true
            } catch {
                print("Failed to configure model container: \(error)")
            }
        }
    }
}
