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
        VStack(
            alignment: settings.textAlignment(for: family),
            spacing: settings.todosSpacing(for: family)
        ) {
            let maxTodos = promptMaxTodos(for: family)
            ForEach(Array(sampleTodos.prefix(maxTodos).enumerated()), id: \.offset) { _, todo in
                let title = settings.isLowercase(for: family) ? todo.0.lowercased() : todo.0

                HStack {
                    if settings.textAlignment(for: family) == .center {
                        Spacer()
                    }

                    Text(title)
                        .font(.system(size: CGFloat(settings.fontSize(for: family))))
                        .lineLimit(1)
                        .strikethrough(todo.1, color: .secondary)
                        .foregroundColor(todo.1 ? .secondary : .primary)

                    if settings.textAlignment(for: family) == .leading
                        || settings.textAlignment(for: family) == .center
                    {
                        Spacer(minLength: 0)
                    }
                }
            }
            if sampleTodos.count < maxTodos {
                Spacer()
            }
        }
        .padding(.horizontal, settings.horizontalPadding(for: family))
        .padding(.vertical, settings.verticalPadding(for: family))
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

    func width(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 150
        case .systemMedium: return 320
        default: return 320
        }
    }

    func height(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 150
        case .systemMedium: return 150
        default: return 320
        }
    }

    func promptMaxTodos(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall: return 3
        case .systemMedium: return 6
        default: return 12
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
