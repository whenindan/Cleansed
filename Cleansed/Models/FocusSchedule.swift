//
//  FocusSchedule.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import Foundation
import SwiftData

@Model
final class FocusSchedule {
    var id: UUID
    var startTime: Date
    var endTime: Date
    var isEnabled: Bool

    init(startTime: Date = Date(), endTime: Date = Date(), isEnabled: Bool = false) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.isEnabled = isEnabled
    }
}
