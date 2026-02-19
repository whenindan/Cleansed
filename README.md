# Cleansed

Cleansed is an iOS productivity app built with SwiftUI and SwiftData. It combines todos, habit tracking, and scheduled focus sessions, and includes a Home Screen widget for quick todo interaction.

## Features

- Todo list with add, delete, and complete actions
- Habit tracking with streaks and historical completion data
- Focus schedule with active/inactive status indicator
- Light and dark appearance setting
- Home Screen widget that can toggle todo completion through App Intents
- Widget appearance controls (font, spacing, alignment, background)

## Architecture and Modules

### App target (`Cleansed/`)

- `Cleansed/CleansedApp.swift`
  - App entry point
  - Configures `ModelContainer` for `TodoItem`, `Habit`, `HabitCompletion`, and `FocusSchedule`
  - Applies persisted dark/light preference
- `Cleansed/Views/MainTabView.swift`
  - Tab navigation: Todos, Habits, Focus, Account
  - Handles widget deep link (`cleansed://todos`)
- `Cleansed/Views/TodoView.swift`
  - SwiftData-backed todo UI
  - Syncs todos to shared `UserDefaults` for widget reads
  - Syncs widget toggles back into SwiftData when app becomes active
- `Cleansed/Views/HabitView.swift`, `Cleansed/Views/HabitDetailView.swift`, `Cleansed/Views/HabitRowView.swift`
  - Habit list, detail stats, and completion interactions
- `Cleansed/Views/FocusView.swift`
  - Focus schedule editor and status UI
- `Cleansed/Views/Account/`
  - `AccountView.swift`: Settings hub
  - `SettingsView.swift`: Appearance settings
  - `WidgetSettingsView.swift` + `WidgetPreviewView.swift`: Widget customization UI
  - `PlanView.swift`: Plan/upgrade placeholder screen
- `Cleansed/Models/`
  - `TodoItem.swift`, `Habit.swift`, `HabitCompletion.swift`, `FocusSchedule.swift`, `WidgetSettings.swift`
- `Cleansed/ViewModels/FocusManager.swift`
  - Focus schedule state and validation logic
- `Cleansed/Managers/TodoManager.swift`
  - Shared todo encoding/decoding for widget communication
  - Widget timeline reload triggers
- `Cleansed/Intents/ToggleTodoIntent.swift`
  - App Intent used by the widget to toggle completion
- `Cleansed/DesignSystem.swift`
  - Shared UI components/modifiers (for example FAB and list styling helpers)

### Widget target (`TodoWidget/`)

- `TodoWidget/TodoWidget.swift`
  - Widget timeline provider and UI
  - Supports `.systemSmall`, `.systemMedium`, `.systemLarge`, `.systemExtraLarge`
- `TodoWidget/TodoWidgetControl.swift` and `TodoWidget/TodoWidgetLiveActivity.swift`
  - Widget extension components
- `TodoWidget/TodoWidgetBundle.swift`
  - Widget bundle entry

## Data and Widget Sync Flow

1. Todos are stored in SwiftData.
2. App writes a simplified todo payload to app-group `UserDefaults` (`group.com.cleansed.shared`).
3. Widget reads shared todos and renders them.
4. Tapping a todo in widget runs `ToggleTodoIntent`.
5. Intent updates shared storage and reloads widget timelines.
6. App syncs widget changes back to SwiftData on foreground/updates.

## Requirements

- Xcode with iOS 17+ SDK support
- iOS 17.0+
- SwiftUI + SwiftData

## Build and Run

1. Open `Cleansed.xcodeproj` in Xcode.
2. Select the `Cleansed` scheme.
3. Build and run on an iOS 17+ simulator or device.
