//
//  GoalsView.swift
//  Kognize
//
//  Placeholder tab until goal creation + on-track/behind logic exist
//  (Build order step 9).
//

import SwiftUI

struct GoalsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "target")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color.kognizePurple)

                Text("No goals yet")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Set a savings or spending goal and Kog will tell you if you're on track.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    GoalsView()
}
