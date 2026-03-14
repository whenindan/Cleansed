//
//  CreateFocusGroupView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/23/26.
//

import FamilyControls
import SwiftData
import SwiftUI

struct CreateFocusGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let screenTimeManager: ScreenTimeManager

    // Form state
    @State private var name = ""
    @State private var selectedIcon = "moon.fill"
    @State private var iconSearchText = ""
    @State private var selectedColorHex = "#5E5CE6"
    @State private var scheduleType: ScheduleType = .manual
    @State private var startHour = 22
    @State private var startMinute = 0
    @State private var endHour = 7
    @State private var endMinute = 0
    @State private var selectedWeekdays: Set<Int> = Set(1...7)
    @State private var timerDuration = 30
    @State private var customTimerDuration: TimeInterval = 45 * 60

    // App selection
    @State private var activitySelection = FamilyActivitySelection()
    @State private var showAppPicker = false

    // Time picker
    @State private var startDate = Calendar.current.date(
        from: DateComponents(hour: 22, minute: 0))!
    @State private var endDate = Calendar.current.date(
        from: DateComponents(hour: 7, minute: 0))!

    private let icons = [
        "flame.fill", "moon.fill", "sun.max.fill", "book.fill",
        "heart.fill", "bolt.fill", "leaf.fill", "star.fill",
        "figure.walk", "music.note", "paintbrush.fill", "drop.fill",
        "pencil", "dumbbell.fill", "brain.head.profile", "bed.double.fill",
        "airplane", "car.fill", "bicycle", "tram.fill",
        "cart.fill", "bag.fill", "creditcard.fill", "banknote.fill",
        "cross.case.fill", "pills.fill", "stethoscope", "syringe.fill",
        "cup.and.saucer.fill", "wineglass.fill", "fork.knife", "takeoutbag.and.cup.and.straw.fill",
        "gamecontroller.fill", "tv.fill", "headphones", "pianokeys",
        "pawprint.fill", "tortoise.fill", "ladybug.fill", "ant.fill",
        "house.fill", "building.2.fill", "tent.fill", "tree.fill",
        "graduationcap.fill", "briefcase.fill", "display", "laptopcomputer",
        "hammer.fill", "wrench.and.screwdriver.fill", "gearshape.fill", "scissors",
        "magnifyingglass", "lightbulb.fill", "camera.fill", "video.fill",
        "mic.fill", "message.fill", "phone.fill", "envelope.fill",
        "mappin.and.ellipse", "map.fill", "clock.fill", "alarm.fill",
        "timer", "stopwatch.fill", "calendar", "list.bullet",
        "checklist", "rosette", "trophy.fill", "medal.fill",
        "gift.fill", "balloon.2.fill", "party.popper.fill", "sparkles",
        "smiley.fill", "hand.thumbsup.fill", "figure.run", "figure.yoga",
        "water.waves", "flame", "drop", "cloud.rain.fill",
    ]

    private var filteredIcons: [String] {
        if iconSearchText.isEmpty {
            return icons
        } else {
            return icons.filter { $0.localizedCaseInsensitiveContains(iconSearchText) }
        }
    }

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

    /// Resolved accent color to avoid repeated optional unwrapping
    private var accentColor: Color {
        Color(hex: selectedColorHex) ?? .purple
    }

    var body: some View {
        NavigationStack {
            Form {
                nameAndAppearanceSection
                appSelectionSection
                scheduleSection
                saveSection
            }
            .navigationTitle("New Focus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .familyActivityPicker(
                isPresented: $showAppPicker,
                selection: $activitySelection
            )
        }
    }

    // MARK: - Sections

    private var nameAndAppearanceSection: some View {
        Section("Name & Appearance") {
            TextField("Focus group name", text: $name)
            iconPickerView
            colorPickerView
        }
    }

    private var iconPickerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search icons...", text: $iconSearchText)
                    .disableAutocorrection(true)

                if !iconSearchText.isEmpty {
                    Button {
                        iconSearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10
                ) {
                    ForEach(filteredIcons, id: \.self) { icon in
                        let isSelected = selectedIcon == icon
                        Button {
                            selectedIcon = icon
                        } label: {
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            isSelected
                                                ? accentColor.opacity(0.2)
                                                : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? accentColor : .clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 200) // Scrollable constrained area
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
                    let isSelected = selectedColorHex == hex
                    Button {
                        selectedColorHex = hex
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
                    Text("Select Apps to Block")
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
            Text("Apps to Block")
        } footer: {
            Text(
                "Choose specific apps or entire categories to block when this focus is active."
            )
        }
    }

    private var scheduleSection: some View {
        Section("Activation Mode") {
            Picker("Mode", selection: $scheduleType) {
                ForEach(ScheduleType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)

            switch scheduleType {
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
                    selection: $startDate,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: startDate) { _, newVal in
                    let comps = Calendar.current.dateComponents(
                        [.hour, .minute], from: newVal)
                    startHour = comps.hour ?? 22
                    startMinute = comps.minute ?? 0
                }

                DatePicker(
                    "End Time",
                    selection: $endDate,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: endDate) { _, newVal in
                    let comps = Calendar.current.dateComponents(
                        [.hour, .minute], from: newVal)
                    endHour = comps.hour ?? 7
                    endMinute = comps.minute ?? 0
                }

                weekdayPicker

            case .timer:
                timerPicker
            }
        }
    }

    private var saveSection: some View {
        Section {
            Button {
                saveGroup()
            } label: {
                let bgColor: Color = name.isEmpty ? .secondary : accentColor
                Text("Create Focus Group")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(bgColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(name.isEmpty)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
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
                    let isSelected = selectedWeekdays.contains(day)
                    Button {
                        if isSelected {
                            selectedWeekdays.remove(day)
                        } else {
                            selectedWeekdays.insert(day)
                        }
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
        CountDownTimerPicker(duration: $customTimerDuration)
            .frame(height: 160)
            .onChange(of: customTimerDuration) { _, seconds in
                timerDuration = max(1, Int(seconds / 60))
            }
    }

    // MARK: - Save

    private func saveGroup() {
        let group = FocusGroup(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColorHex,
            isEnabled: false,
            scheduleType: scheduleType,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            weekdays: Array(selectedWeekdays).sorted(),
            timerDuration: timerDuration,
            selectedAppTokens: ScreenTimeShared.encode(activitySelection)
        )

        // Store selection in shared defaults
        ScreenTimeShared.storeSelection(activitySelection, for: group.id)

        modelContext.insert(group)
        dismiss()
    }
}
