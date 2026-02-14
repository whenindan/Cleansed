//
//  HabitCompletion.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import Foundation
import SwiftData

@Model
final class HabitCompletion {
    var id: UUID
    var date: Date
    var habit: Habit?

    init(date: Date, habit: Habit) {
        self.id = UUID()
        self.date = date
        self.habit = habit
    }
}
