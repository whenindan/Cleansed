//
//  FocusView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import DeviceActivity
import FamilyControls
import SwiftData
import SwiftUI

struct FocusView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FocusGroup.createdAt, order: .reverse) private var focusGroups: [FocusGroup]

    @State private var screenTimeManager = ScreenTimeManager()
    @State private var showCreateSheet = false
    @State private var selectedGroup: FocusGroup?
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Authorization Banner
                    if !screenTimeManager.isAuthorized {
                        authorizationBanner
                    }

                    // MARK: - Focus Groups
                    if focusGroups.isEmpty && screenTimeManager.isAuthorized {
                        emptyState
                    } else {
                        focusGroupsList
                    }

                    // MARK: - Screen Time Statistics
                    if screenTimeManager.isAuthorized {
                        statisticsSection
                    }

                    Spacer(minLength: 80)
                }
                .padding(.top, 8)
            }

            // MARK: - FAB
            if screenTimeManager.isAuthorized {
                FAB {
                    showCreateSheet = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            screenTimeManager.checkAuthorization()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateFocusGroupView(screenTimeManager: screenTimeManager)
        }
        .sheet(item: $selectedGroup) { group in
            FocusGroupDetailView(group: group, screenTimeManager: screenTimeManager)
        }
    }

    // MARK: - Authorization Banner

    private var authorizationBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "hourglass.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(Color.primary)

            Text("Screen Time Access Required")
                .font(.headline)

            Text(
                "Grant Screen Time access to create focus sessions that block distracting apps."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            } label: {
                Text("Grant Access")
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("No Focus Groups")
                .font(.headline)

            Text("Create a focus group to start blocking distracting apps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 16)
    }

    // MARK: - Focus Groups List

    private var focusGroupsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Groups")
                .font(.headline)
                .padding(.horizontal, 16)

            ForEach(focusGroups) { group in
                FocusGroupRow(
                    group: group,
                    screenTimeManager: screenTimeManager,
                    onTap: {
                        selectedGroup = group
                    },
                    onDelete: {
                        deleteGroup(group)
                    }
                )
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Screen Time")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.blue)
                    Text("Device Activity")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }

                // DeviceActivityReport is rendered via an extension.
                // We display a placeholder + embed the report view.
                DeviceActivityReportContainer()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Actions

    private func deleteGroup(_ group: FocusGroup) {
        screenTimeManager.removeGroup(group)
        modelContext.delete(group)
    }
}

// MARK: - Focus Group Row

struct FocusGroupRow: View {
    @Bindable var group: FocusGroup
    let screenTimeManager: ScreenTimeManager
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                Image(systemName: group.icon)
                    .font(.title3)
                    .foregroundStyle(group.color)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(group.color.opacity(0.15))
                    )

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.primary)

                    Text(group.scheduleDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Toggle
                Toggle(
                    "",
                    isOn: Binding(
                        get: { group.isEnabled },
                        set: { newValue in
                            screenTimeManager.toggleGroup(group, enabled: newValue)
                        }
                    )
                )
                .labelsHidden()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog("Delete \"\(group.name)\"?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will remove the focus group and lift any active blocks.")
        }
    }
}

// MARK: - Device Activity Report Container

struct DeviceActivityReportContainer: View {
    // Filter for the past 7 days
    private var filter: DeviceActivityFilter {
        let now = Date()
        let startOfWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: startOfWeek, end: now))
        )
    }

    var body: some View {
        DeviceActivityReport(
            DeviceActivityReport.Context("TotalActivity"),
            filter: filter
        )
    }
}

#Preview {
    FocusView()
        .modelContainer(for: FocusGroup.self, inMemory: true)
}
