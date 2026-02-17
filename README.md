# Cleansed - Productivity & Habit Tracker

Cleansed is a comprehensive iOS productivity application built with **SwiftUI** and **SwiftData**. It combines habit tracking, task management, and scheduled focus sessions into a unified, minimalist interface.

## Project Structure

The project is organized into logical groups based on the MVVM architecture and feature sets.

### 📱 Entry Point

- **`CleansedApp.swift`**: The main entry point of the application. It sets up the SwiftData `ModelContainer` for persisting user data (Habits, Todos, Focus Schedules) with automatic migration support. It also handles app lifecycle events and configures theme preferences (Dark/Light mode).

### 🗂️ Models

Located in the `Models/` directory, these files define the data structure and business logic.

- **`Habit.swift`**: Defines the `Habit` entity. Includes logic for:
  - Tracking habit properties (`name`, `startDate`, `createdAt`).
  - Calculating statistics: current streak, best streak, and completion rates.
  - Managing relationships with `HabitCompletion`.
- **`HabitCompletion.swift`**: Represents a single completion record for a habit on a specific date. Linked to a `Habit`.
- **`TodoItem.swift`**: Defines a task in the To-Do list, including its completion status (`isCompleted`) and creation timestamp.
- **`FocusSchedule.swift`**: (Presumed) Model for storing focus timer schedules or history.

### 🖼️ Views

Located in the `Views/` directory, these are the UI components of the application.

- **`MainTabView.swift`**: The root view that manages navigation between the main features: Todos, Habits, Focus, and Account.
- **`TodoView.swift`**: Displays the list of tasks. Allows users to add new tasks, mark them as complete, and delete them.
- **`HabitView.swift`**: The main dashboard for habits.
  - Lists all active habits with their current streak.
  - Allows creating new habits with a specific start date.
  - Provides navigation to detailed habit statistics.
- **`HabitRowView.swift`**: A reusable component representing a single habit row.
  - Displays the habit name and current streak.
  - Renders a horizontal list of the last 7 days with interactive completion circles.
  - Includes a visual "fire" indicator for active streaks.
- **`HabitDetailView.swift`**: A detailed view for a specific habit.
  - Shows comprehensive statistics: Current Streak, Best Streak, Completion Rate.
  - Displays a monthly calendar grid to visualize consistency and toggle past completions.
  - Allows navigation between months.
- **`FocusView.swift`**: Implementation of the scheduled Focus Mode feature.
  - Allows users to schedule start and end times for focus sessions.
  - Displays current active/inactive status.
- **`Account/AccountView.swift`**: View related to user account settings and theme customization.

### 🧠 ViewModels

Located in the `ViewModels/` directory.

- **`FocusManager.swift`**: Manages the state and logic for the Focus Mode (scheduling, time window validation).

### 🎨 Design System

- **`DesignSystem.swift`**: Centralized definition of reusable UI components and modifiers.
  - `MinimalistCheckboxStyle`: Custom toggle style for To-Do items.
  - `FAB`: Floating Action Button component used for adding new items.
  - `HideListSeparators`: View modifier to remove default list separators for a cleaner look.

## Features

1.  **Habit Tracking**:
    -   Create habits with custom start dates.
    -   Track daily completions.
    -   Visualize streaks and historical data on a navigable calendar.
    -   Smart stats calculation (days since start date).
2.  **Task Management**:
    -   Simple, checklist-style To-Do list with minimalist design.
3.  **Focus Mode**:
    -   Schedule daily focus windows to minimize distractions.
4.  **Customization**:
    -   Support for Dark and Light modes.

## Tech Stack

-   **Language**: Swift 5+
-   **UI Framework**: SwiftUI
-   **Persistence**: SwiftData (with automatic migration)
-   **Minimum Deployment Target**: iOS 17.0+
