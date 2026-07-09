//
//  GoalsView.swift
//  Kognize
//
//  Goals live in memory only for now — no persistence layer yet.
//

import SwiftUI

struct GoalsView: View {
    @State private var goals: [Goal] = []
    @State private var isAddGoalPresented = false

    var body: some View {
        NavigationStack {
            Group {
                if goals.isEmpty {
                    emptyState
                } else {
                    goalList
                }
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                // Leading, not trailing -- the floating hamburger menu is
                // always pinned top-right across every tab, so any
                // per-screen action button belongs on the left to avoid
                // sitting underneath it.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isAddGoalPresented = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.kognizePurple)
                    }
                }
            }
        }
        .sheet(isPresented: $isAddGoalPresented) {
            AddGoalView { goal in
                goals.append(goal)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "target")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(Color.kognizePurple)

            Text("No goals yet")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Set a savings or spending goal and Kog will tell you if you're on track.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                isAddGoalPresented = true
            } label: {
                Text("Add a Goal")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.kognizePurple))
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    private var goalList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(goals) { goal in
                    NavigationLink {
                        GoalDetailView(goal: goal)
                    } label: {
                        GoalRow(goal: goal)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    GoalsView()
}
