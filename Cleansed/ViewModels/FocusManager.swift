//
//  FocusManager.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import Foundation
import SwiftUI

@Observable
final class FocusManager {
    var startTime: Date
    var endTime: Date
    var isEnabled: Bool

    init(startTime: Date = Date(), endTime: Date = Date(), isEnabled: Bool = false) {
        self.startTime = startTime
        self.endTime = endTime
        self.isEnabled = isEnabled
    }

    // Check if current time falls within the focus window
    func isCurrentlyInFocusWindow() -> Bool {
        guard isEnabled else { return false }

        let calendar = Calendar.current
        let now = Date()

        // Extract time components
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)

        guard let startHour = startComponents.hour,
            let startMinute = startComponents.minute,
            let endHour = endComponents.hour,
            let endMinute = endComponents.minute,
            let nowHour = nowComponents.hour,
            let nowMinute = nowComponents.minute
        else {
            return false
        }

        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let nowMinutes = nowHour * 60 + nowMinute

        // Handle cases where end time is before start time (crosses midnight)
        if endMinutes < startMinutes {
            return nowMinutes >= startMinutes || nowMinutes <= endMinutes
        } else {
            return nowMinutes >= startMinutes && nowMinutes <= endMinutes
        }
    }

    func updateSchedule(startTime: Date, endTime: Date, isEnabled: Bool) {
        self.startTime = startTime
        self.endTime = endTime
        self.isEnabled = isEnabled
    }
}
