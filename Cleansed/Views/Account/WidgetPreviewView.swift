//
//  WidgetPreviewView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/17/26.
//

import SwiftUI
import WidgetKit

/// Live preview of widget with current settings
struct WidgetPreviewView: View {
    let settings = WidgetSettings.shared
    var family: WidgetFamily = .systemLarge

    let sampleTodos = [
        ("1 leetcode question", false),
        ("book hair appointment", false),
        ("buy air tickets to shanghai", false),
        ("improve paywall page", false),
        ("tutoring eric", false),
        ("tutoring alexandra", true),
        ("jp morgan chase & co. - codi...", true),
    ]

    var body: some View {

        TodoWidgetContentView(family: family, entry: createSampleEntry())
            .frame(width: width(for: family), height: height(for: family))
            .background(
                Group {
                    if settings.useCustomBackground(for: family) {
                        settings.backgroundColorValue(for: family)
                    } else {
                        // Glass effect for default system theme
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                }
            )
            .cornerRadius(20)
            // Add a subtle border to frame the preview
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    func createSampleEntry() -> TodoEntry {
        TodoEntry(
            date: Date(),
            todos: sampleTodos.map { title, isCompleted in
                TodoItemData(
                    id: UUID(),
                    title: title,
                    isCompleted: isCompleted,
                    createdAt: Date(),
                    completedAt: isCompleted ? Date() : nil,
                    sortDate: Date()
                )
            })
    }

    func width(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 158  // iOS 16+ Standard Small Width
        case .systemMedium: return 338  // iOS 16+ Standard Medium Width
        default: return 338  // Large Width matches Medium
        }
    }

    func height(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 158  // iOS 16+ Standard Small Height
        case .systemMedium: return 158  // iOS 16+ Standard Medium Height
        default: return 354  // iOS 16+ Standard Large Height
        }
    }
}

#Preview {
    VStack {
        Text("Small")
        WidgetPreviewView(family: .systemSmall)
        Text("Medium")
        WidgetPreviewView(family: .systemMedium)
        Text("Large")
        WidgetPreviewView(family: .systemLarge)
    }
    .padding()
}
