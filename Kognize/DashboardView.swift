//
//  DashboardView.swift
//  Kognize
//
//  Static placeholder data — real score data arrives once the Kog scoring
//  endpoint exists (Build order step 5). Shows the most necessary data up
//  front; the Accounts card drills into detail rather than living inline.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    scoreCard
                    accountsCard
                }
                .padding(20)
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var scoreCard: some View {
        VStack(spacing: 12) {
            Text("Today's Score")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: 0.82)
                    .stroke(Color.kognizePurple, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("82")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Healthy")
                        .font(.subheadline)
                        .foregroundStyle(Color.kognizePurple)
                }
            }
            .frame(width: 140, height: 140)

            Text("Spending is on track with your typical month.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.kognizePurple.opacity(0.3), lineWidth: 1)
        )
    }

    private var accountsCard: some View {
        NavigationLink {
            AccountsDetailView()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Accounts")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Bank, investments, and manual entries")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView()
}
