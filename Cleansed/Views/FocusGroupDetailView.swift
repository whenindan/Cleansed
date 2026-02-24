//
//  FocusGroupDetailView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/23/26.
//

import FamilyControls
import SwiftUI

struct FocusGroupDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var group: FocusGroup
    let screenTimeManager: ScreenTimeManager

    @State private var activitySelection = FamilyActivitySelection()
    @State private var showAppPicker = false
    @State private var editedName: String = ""
    @State private var editedIcon: String = ""
    @State private var editedColorHex: String = ""
    @State private var editedScheduleType: ScheduleType = .manual
    @State private var editedStartDate = Date()
    @State private var editedEndDate = Date()
    @State private var editedWeekdays: Set<Int> = []
    @State private var editedTimerDuration: Int = 30

    private let icons = [
        "moon.fill", "sun.max.fill", "briefcase.fill", "book.fill",
        "laptopcomputer", "gamecontroller.fill", "bed.double.fill",
        "figure.walk", "heart.fill", "graduationcap.fill",
        "paintbrush.fill", "music.note", "leaf.fill", "flame.fill",
        "bolt.fill", "eye.slash.fill",
    ]

    private let colors: [(String, String)] = [
        ("#5E5CE6", "Indigo"),
        ("#FF6B6B", "Red"),
        ("#FFB347", "Orange"),
        ("#48C774", "Green"),
        ("#3B82F6", "Blue"),
        ("#A855F7", "Purple"),
        ("#EC4899", "Pink"),
        ("#14B8A6", "Teal"),
        ("#F59E0B", "Amber"),
        ("#6B7280", "Gray"),
    ]

    private var accentColor: Color {
        Color(hex: editedColorHex) ?? .purple
    }

    var body: some View {
        NavigationStack {
            Form {
                statusSection
                nameAndAppearanceSection
                appSelectionSection
                scheduleSection
            }
            .navigationTitle(group.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .familyActivityPicker(
                isPresented: $showAppPicker,
                selection: $activitySelection
            )
            .onChange(of: activitySelection) { _, newSelection in
                screenTimeManager.updateSelection(for: group, selection: newSelection)
            }
            .onAppear {
                loadGroupState()
            }
        }
    }

    // MARK: - Sections

    private var statusSection: some View {
        Section {
            HStack {
                Text("Status")
                Spacer()
                HStack(spacing: 8) {
                    Circle()
                        .fill(group.isEnabled ? Color.green : Color.secondary)
                        .frame(width: 10, height: 10)
                    Text(group.isEnabled ? "Active" : "Inactive")
                        .foregroundStyle(group.isEnabled ? .green : .secondary)
                        .fontWeight(.medium)
                }
            }

            Toggle(
                "Enabled",
                isOn: Binding(
                    get: { group.isEnabled },
                    set: { newValue in
                        screenTimeManager.toggleGroup(group, enabled: newValue)
                    }
                ))
        }
    }

    private var nameAndAppearanceSection: some View {
        Section("Name & Appearance") {
            TextField("Name", text: $editedName)
                .onChange(of: editedName) { _, newVal in
                    group.name = newVal
                }
            iconPickerView
            colorPickerView
        }
    }

    private var iconPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Icon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 8),
                spacing: 10
            ) {
                ForEach(icons, id: \.self) { icon in
                    let isSelected = editedIcon == icon
                    Button {
                        editedIcon = icon
                        group.icon = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.title3)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? accentColor.opacity(0.2) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? accentColor : .clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var colorPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 5),
                spacing: 10
            ) {
                ForEach(colors, id: \.0) { hex, _ in
                    let chipColor = Color(hex: hex) ?? .gray
                    let isSelected = editedColorHex == hex
                    Button {
                        editedColorHex = hex
                        group.colorHex = hex
                    } label: {
                        Circle()
                            .fill(chipColor)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: isSelected ? 3 : 0)
                            )
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .opacity(isSelected ? 1 : 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var appSelectionSection: some View {
        Section {
            Button {
                showAppPicker = true
            } label: {
                HStack {
                    Image(systemName: "app.badge")
                        .foregroundStyle(accentColor)
                    Text("Edit Blocked Apps")
                    Spacer()
                    let count =
                        activitySelection.applicationTokens.count
                        + activitySelection.categoryTokens.count
                    if count > 0 {
                        Text("\(count) selected")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        } header: {
            Text("Blocked Apps")
        }
    }

    private var scheduleSection: some View {
        Section("Activation Mode") {
            Picker("Mode", selection: $editedScheduleType) {
                ForEach(ScheduleType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: editedScheduleType) { _, newVal in
                group.scheduleType = newVal
            }

            switch editedScheduleType {
            case .manual:
                HStack {
                    Image(systemName: "hand.tap")
                        .foregroundStyle(.secondary)
                    Text("Toggle this focus group on or off manually.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

            case .scheduled:
                DatePicker(
                    "Start Time",
                    selection: $editedStartDate,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: editedStartDate) { _, newVal in
                    let comps = Calendar.current.dateComponents(
                        [.hour, .minute], from: newVal)
                    group.startHour = comps.hour ?? 22
                    group.startMinute = comps.minute ?? 0
                }

                DatePicker(
                    "End Time",
                    selection: $editedEndDate,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: editedEndDate) { _, newVal in
                    let comps = Calendar.current.dateComponents(
                        [.hour, .minute], from: newVal)
                    group.endHour = comps.hour ?? 7
                    group.endMinute = comps.minute ?? 0
                }

                weekdayPicker

            case .timer:
                timerPicker
            }
        }
    }

    // MARK: - Weekday Picker

    private var weekdayPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repeat on")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { day in
                    let symbol = Calendar.current.shortWeekdaySymbols[day - 1]
                    let isSelected = editedWeekdays.contains(day)
                    Button {
                        if isSelected {
                            editedWeekdays.remove(day)
                        } else {
                            editedWeekdays.insert(day)
                        }
                        group.weekdays = Array(editedWeekdays).sorted()
                    } label: {
                        Text(String(symbol.prefix(2)))
                            .font(.caption.bold())
                            .frame(width: 36, height: 36)
                            .background(isSelected ? accentColor : Color(.tertiarySystemFill))
                            .foregroundStyle(isSelected ? .white : Color.primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Timer Picker

    private var timerPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Block for")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 2),
                spacing: 10
            ) {
                ForEach(TimerDuration.allCases) { duration in
                    let selected = isTimerSelected(duration)
                    Button {
                        if duration == .custom {
                            editedTimerDuration = 45
                        } else {
                            editedTimerDuration = duration.rawValue
                        }
                        group.timerDuration = editedTimerDuration
                    } label: {
                        Text(duration.label)
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selected ? accentColor : Color(.tertiarySystemFill))
                            )
                            .foregroundStyle(selected ? .white : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if isCustomTimer {
                Stepper(
                    "Custom: \(editedTimerDuration) min",
                    value: $editedTimerDuration,
                    in: 5...480,
                    step: 5
                )
                .onChange(of: editedTimerDuration) { _, newVal in
                    group.timerDuration = newVal
                }
            }
        }
    }

    private func isTimerSelected(_ duration: TimerDuration) -> Bool {
        if duration == .custom {
            return isCustomTimer
        }
        return editedTimerDuration == duration.rawValue && !isCustomTimer
    }

    private var isCustomTimer: Bool {
        ![30, 60, 120, 240].contains(editedTimerDuration)
    }

    // MARK: - Load State

    private func loadGroupState() {
        editedName = group.name
        editedIcon = group.icon
        editedColorHex = group.colorHex
        editedScheduleType = group.scheduleType
        editedWeekdays = Set(group.weekdays)
        editedTimerDuration = group.timerDuration

        editedStartDate =
            Calendar.current.date(
                from: DateComponents(hour: group.startHour, minute: group.startMinute))
            ?? Date()
        editedEndDate =
            Calendar.current.date(
                from: DateComponents(hour: group.endHour, minute: group.endMinute)) ?? Date()

        // Load app selection
        screenTimeManager.loadSelection(for: group)
        activitySelection = screenTimeManager.activitySelection
    }
}
