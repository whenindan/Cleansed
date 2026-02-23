# Cleansed

Cleansed is an iOS productivity app built with SwiftUI and SwiftData. It combines:

- Todo management
- Habit tracking with completion history
- Time-based focus scheduling
- A Home Screen widget with interactive todo toggles

## Tech Stack

- Swift 5
- SwiftUI
- SwiftData
- WidgetKit + App Intents
- Xcode project (`Cleansed.xcodeproj`)

## Project Structure

- `Cleansed/` - Main app target
- `TodoWidget/` - Widget extension target
- `CleansedTests/` - Unit test target
- `CleansedUITests/` - UI test target

## Core Features

- Todos
  - Create, complete/uncomplete, and delete tasks
  - Ordering behavior tuned for quick capture and recent interactions
- Habits
  - Track completions and view history/streak-oriented details
- Focus
  - Enable/disable daily focus windows with start/end schedule and active status indicator
- Appearance
  - In-app dark mode toggle via app storage
- Widget
  - Displays shared todos on Home Screen
  - Supports `.systemSmall`, `.systemMedium`, `.systemLarge`, `.systemExtraLarge`
  - Tapping a widget item triggers `ToggleTodoIntent` to update completion
  - Widget style controls for text, spacing, alignment, and background color

## Data + Widget Sync

Todo data is synchronized between app and widget through app-group `UserDefaults`:

1. SwiftData stores canonical app todo records.
2. App serializes todos to shared defaults (`group.com.cleansed.shared`).
3. Widget reads shared payload for timeline rendering.
4. Widget actions call `ToggleTodoIntent`.
5. Intent updates shared payload and reloads widget timelines.
6. App syncs shared changes back into SwiftData when active.

## Requirements

- macOS with Xcode installed
- Xcode with iOS 17 SDK
- iOS 17.0+ deployment target

## Setup

1. Open `Cleansed.xcodeproj` in Xcode.
2. Select the `Cleansed` scheme and an iOS 17+ simulator/device.
3. Ensure both app target and widget target use the same App Group:
   - `group.com.cleansed.shared`
4. Build and run.

## Running Tests

From Xcode:

- `Product` -> `Test`

From command line:

```bash
xcodebuild test \
  -project Cleansed.xcodeproj \
  -scheme Cleansed \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Main Files

- `Cleansed/CleansedApp.swift` - App entry + SwiftData container
- `Cleansed/Views/MainTabView.swift` - Tab navigation + deep link handling
- `Cleansed/Views/TodoView.swift` - Todo UI and widget sync hooks
- `Cleansed/Managers/TodoManager.swift` - Shared todo encoding/decoding and widget reload
- `Cleansed/Intents/ToggleTodoIntent.swift` - Widget interaction intent
- `Cleansed/Models/WidgetSettings.swift` - Shared widget appearance settings
- `TodoWidget/TodoWidget.swift` - Widget provider + configuration

## Notes

- The Focus tab includes a placeholder app-blocking action that requires additional Apple entitlements.
- Widget integration depends on properly configured App Group capabilities in Signing & Capabilities.
