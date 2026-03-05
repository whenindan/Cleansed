# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

Open `Cleansed.xcodeproj` in Xcode and run the `Cleansed` scheme on a simulator or device. All targets require signing with an Apple Developer account that has App Groups, FamilyControls, and DeviceActivity entitlements.

Run tests from command line:
```bash
xcodebuild test \
  -project Cleansed.xcodeproj \
  -scheme Cleansed \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

**Tech stack:** Swift/SwiftUI + SwiftData (local) + Supabase (cloud sync) + WidgetKit + FamilyControls

### Targets
- `Cleansed/` — Main app
- `TodoWidget/` — Home Screen widget with interactive todo toggles
- `DeviceActivityMonitorExtension/` — Focus session lifecycle
- `DeviceActivityReportExtension/` — Screen time report scene
- `ShieldActionExtension/` / `ShieldConfigurationExtension/` — App blocking UI

### Data Layer

Two parallel storage systems:
1. **SwiftData** — local source of truth for the main app (`TodoItem`, `Habit`, `HabitCompletion`, `FocusGroup`). Container is the app's own container, **not** App Group (App Group causes Error 512 on first launch).
2. **Supabase** — cloud backend. All API calls go through `SupabaseManager` (singleton). Tables: `profiles`, `habits`, `habit_completions`, `todo_items`.

`DataSyncManager` coordinates between the two: loads from Supabase into SwiftData on sign-in, migrates guest data on account creation, and clears local data on sign-out.

**Widget bridge:** `TodoManager` serializes SwiftData todos to `UserDefaults(suiteName: "group.com.cleansed.shared")` as JSON, then calls `WidgetCenter.shared.reloadTimelines`. The widget reads from this UserDefaults key; it never touches SwiftData directly. `ToggleTodoIntent` also writes back to UserDefaults when the user taps a todo from the widget.

### Auth Flow

`AuthManager` (ObservableObject, injected as `@EnvironmentObject`) tracks `isAuthenticated` and `isGuest`. The app root in `CleansedApp` shows `SignInView` or `MainTabView` based on these states. Guest mode allows full local use; converting to an account triggers `DataSyncManager.migrateGuestData`.

### Design System

`DesignSystem.swift` defines shared UI primitives:
- `MinimalistCheckboxStyle` — `ToggleStyle` used for todo/habit rows
- `FAB` — floating action button (plus icon, primary color)
- `HideListSeparators` — view modifier for plain list style without separators

## Critical Patterns

**SwiftData deletion order:** Always delete `HabitCompletion` records before `Habit` records. The relationship is mandatory, so deleting a `Habit` first causes a constraint violation. Never use `context.delete(model:)` batch delete — always fetch and delete individually.

**Supabase client:** Defined as a module-level global `supabase` in `SupabaseClient.swift`. All targets that need Supabase import this file.

**Widget sort order:** Incomplete todos first (sorted by `sortDate` ascending), completed todos last (sorted by `completedAt` descending). This logic lives in `TodoManager.sorted(_:)`.
