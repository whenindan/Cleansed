//
//  MainTabView.swift
//  Cleansed
//
//  Created by Nguyen Trong Dat on 2/14/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodoView()
                .tabItem {
                    Label("Todos", systemImage: "list.bullet")
                }

            HabitView()
                .tabItem {
                    Label("Habits", systemImage: "square.grid.2x2")
                }

            FocusView()
                .tabItem {
                    Label("Focus", systemImage: "hourglass")
                }
        }
        .tint(Color.primary)  // Black in Light, White in Dark
    }
}

#Preview {
    MainTabView()
}
