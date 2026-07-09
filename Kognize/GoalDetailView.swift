//
//  GoalDetailView.swift
//  Kognize
//

import SwiftUI

struct GoalRow: View {
    let goal: Goal

    private var progress: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.currentAmount / goal.targetAmount, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: goal.type.icon)
                    .foregroundStyle(Color.kognizePurple)
                Text(goal.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text(goal.type.rawValue)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            ProgressView(value: progress)
                .tint(Color.kognizePurple)

            Text("£\(Int(goal.currentAmount)) of £\(Int(goal.targetAmount))")
                .font(.footnote)
                .foregroundStyle(.primary)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.05)))
    }
}

struct GoalDetailView: View {
    let goal: Goal

    private var progress: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.currentAmount / goal.targetAmount, 1)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: goal.type.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.kognizePurple)
                    Text(goal.name)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    Text(goal.type.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .padding(.top, 12)

                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .tint(Color.kognizePurple)
                    Text("£\(Int(goal.currentAmount)) of £\(Int(goal.targetAmount))")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.05)))
                .padding(.horizontal, 20)

                if goal.hasAdvancedDetails {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Details")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if let targetDate = goal.targetDate {
                            detailRow(label: "Target date", value: targetDate.formatted(date: .abbreviated, time: .omitted))
                        }
                        if let monthly = goal.monthlyContribution {
                            detailRow(label: "Monthly contribution", value: "£\(Int(monthly))")
                        }
                        if let rate = goal.interestRate {
                            detailRow(label: "Interest rate", value: "\(rate.formatted())%")
                        }
                        if let payment = goal.monthlyPayment {
                            detailRow(label: "Monthly payment", value: "£\(Int(payment))")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.05)))
                    .padding(.horizontal, 20)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.kognizePurple)
                        Text("Kog's take")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    Text("You're on track to hit this goal. Keep going!")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.05)))
                .padding(.horizontal, 20)

                Spacer(minLength: 20)
            }
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: Goal(name: "Emergency Fund", type: .emergencyFund, targetAmount: 3000, currentAmount: 1200))
    }
}
