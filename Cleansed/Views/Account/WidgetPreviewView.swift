//
//  WidgetPreviewView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/17/26.
//

import SwiftUI

/// Live preview of widget with current settings
struct WidgetPreviewView: View {
    let settings = WidgetSettings.shared

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
        VStack(alignment: settings.textAlignment, spacing: CGFloat(settings.todosSpacing)) {
            ForEach(Array(sampleTodos.prefix(5).enumerated()), id: \.offset) { _, todo in
                let title = settings.isLowercase ? todo.0.lowercased() : todo.0

                HStack {
                    if settings.textAlignment == .center {
                        Spacer()
                    }

                    Text(title)
                        .font(.system(size: CGFloat(settings.fontSize)))
                        .lineLimit(1)
                        .strikethrough(todo.1, color: .secondary)
                        .foregroundColor(todo.1 ? .secondary : .primary)

                    if settings.textAlignment == .leading || settings.textAlignment == .center {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(.horizontal, CGFloat(settings.horizontalPadding))
        .padding(.vertical, CGFloat(settings.verticalPadding))
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            settings.useCustomBackground
                ? settings.backgroundColorValue
                : Color(UIColor.systemBackground)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    WidgetPreviewView()
        .padding()
}
