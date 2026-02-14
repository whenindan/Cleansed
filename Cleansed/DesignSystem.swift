//
//  DesignSystem.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import SwiftUI

struct MinimalistCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 16) {
                // Checkbox Circle
                Image(systemName: configuration.isOn ? "circle.inset.filled" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.primary)

                configuration.label
                    .foregroundStyle(configuration.isOn ? Color.secondary : Color.primary)
                    .strikethrough(configuration.isOn, color: Color.secondary)

                Spacer()  // Ensure it takes full width for tap target
            }
            .contentShape(Rectangle())  // Make entire row tappable
        }
        .buttonStyle(.plain)
    }
}

struct FAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(.systemBackground))  // Inverse of background
                .frame(width: 56, height: 56)
                .background(Color.primary)  // Black in Light, White in Dark
                .clipShape(Circle())
                .shadow(color: Color.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// Custom View Modifier for hiding list separators
struct HideListSeparators: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
    }
}

extension View {
    func hideListSeparators() -> some View {
        modifier(HideListSeparators())
    }
}
