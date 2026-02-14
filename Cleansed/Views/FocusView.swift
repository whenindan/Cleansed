//
//  FocusView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import SwiftUI

struct FocusView: View {
    @State private var focusManager = FocusManager()
    @State private var currentTime = Date()

    // Timer to update current time every minute
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var isActive: Bool {
        focusManager.isCurrentlyInFocusWindow()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Focus")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                Form {
                    Section {
                        Toggle("Enable Focus Mode", isOn: $focusManager.isEnabled)
                    }

                    Section("Schedule") {
                        DatePicker(
                            "Start Time", selection: $focusManager.startTime,
                            displayedComponents: .hourAndMinute)

                        DatePicker(
                            "End Time", selection: $focusManager.endTime,
                            displayedComponents: .hourAndMinute)
                    }
                    .disabled(!focusManager.isEnabled)

                    Section {
                        // Status indicator
                        HStack {
                            Text("Status")
                                .foregroundStyle(Color.primary)

                            Spacer()

                            HStack(spacing: 8) {
                                Circle()
                                    .fill(isActive ? Color.green : Color.secondary)
                                    .frame(width: 12, height: 12)

                                Text(isActive ? "Active" : "Inactive")
                                    .foregroundStyle(isActive ? Color.green : Color.secondary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }

                    Section {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "app.badge")
                                Text("Select Apps to Block")
                            }
                        }
                        .disabled(true)
                    } footer: {
                        Text(
                            "App blocking requires Screen Time API entitlements. This feature is currently unavailable without Apple Developer Program enrollment."
                        )
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How Focus Mode Works")
                                .font(.headline)

                            Text(
                                "When active, Focus Mode helps you stay productive by limiting distractions during your scheduled time window."
                            )
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

#Preview {
    FocusView()
}
