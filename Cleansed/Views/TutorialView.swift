//
//  TutorialView.swift
//  Cleansed
//
//  Created by Gemini CLI on 3/20/26.
//

import SwiftUI

struct TutorialPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    let pages: [TutorialPage] = [
        TutorialPage(
            title: "Welcome to Cleansed",
            description: "A minimalist approach to managing your productivity and digital focus.",
            icon: "leaf.fill"
        ),
        TutorialPage(
            title: "Focus on What Matters",
            description: "Set focus schedules to block distracting apps and regain your time.",
            icon: "hourglass"
        ),
        TutorialPage(
            title: "Build Better Habits",
            description: "Track your daily routines and complete tasks with ease.",
            icon: "checkmark.circle.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // Top Skip Button
                HStack {
                    Spacer()
                    Button("Skip") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        TutorialPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Spacer()
                
                // Bottom Navigation
                HStack {
                    Spacer()
                    
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            dismiss()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemBackground))
                        }
                        .shadow(color: Color.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: page.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.primary)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
    }
}

#Preview {
    TutorialView()
}
