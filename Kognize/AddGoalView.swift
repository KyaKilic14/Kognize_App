//
//  AddGoalView.swift
//  Kognize
//
//  Multi-step MCQ-style goal creation. Minimal required fields (type,
//  name, amount) with an optional "Advanced" step for everything else.
//

import SwiftUI

private enum AddGoalStep: Int {
    case type
    case basics
    case advanced
}

struct AddGoalView: View {
    let onCreate: (Goal) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var step: AddGoalStep = .type
    @State private var selectedType: GoalType?
    @State private var name = ""
    @State private var amountText = ""
    @State private var monthlyContributionText = ""
    @State private var interestRateText = ""
    @State private var monthlyPaymentText = ""
    @State private var hasTargetDate = false
    @State private var targetDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        switch step {
                        case .type: typeStep
                        case .basics: basicsStep
                        case .advanced: advancedStep
                        }
                    }
                    .padding(24)
                }

                footerButtons
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach([AddGoalStep.type, .basics, .advanced], id: \.self) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? Color.kognizePurple : Color.primary.opacity(0.15))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private var typeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What kind of goal is this?")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            ForEach(GoalType.allCases) { type in
                Button {
                    selectedType = type
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: type.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.kognizePurple)
                            .frame(width: 32)

                        Text(type.rawValue)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        if selectedType == type {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.kognizePurple)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.primary.opacity(selectedType == type ? 0.1 : 0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(selectedType == type ? Color.kognizePurple : .clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var basicsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The basics")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            labeledField(
                title: "Goal name",
                placeholder: "e.g. New car, Credit card payoff",
                text: $name,
                keyboard: .default
            )

            labeledField(
                title: selectedType == .debtReduction ? "Amount owed" : "Target amount",
                placeholder: "£0",
                text: $amountText,
                keyboard: .decimalPad
            )
        }
    }

    private var advancedStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add more detail")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Everything here is optional — skip anything you don't want to fill in yet.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if selectedType == .debtReduction {
                labeledField(title: "Interest rate (%)", placeholder: "Optional", text: $interestRateText, keyboard: .decimalPad)
                labeledField(title: "Monthly payment", placeholder: "Optional", text: $monthlyPaymentText, keyboard: .decimalPad)
            } else {
                labeledField(title: "Monthly contribution", placeholder: "Optional", text: $monthlyContributionText, keyboard: .decimalPad)

                Toggle("Set a target date", isOn: $hasTargetDate.animation())
                    .tint(Color.kognizePurple)
                    .foregroundStyle(.primary)

                if hasTargetDate {
                    DatePicker("Target date", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(Color.kognizePurple)
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private func labeledField(title: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                .foregroundStyle(.primary)
        }
    }

    private var footerButtons: some View {
        VStack(spacing: 12) {
            if step == .basics {
                Button("Add more detail (optional)") {
                    withAnimation { step = .advanced }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Button(action: primaryAction) {
                Text(primaryButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(primaryButtonEnabled ? Color.kognizePurple : Color.kognizePurple.opacity(0.3))
                    )
            }
            .disabled(!primaryButtonEnabled)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    private var primaryButtonTitle: String {
        step == .advanced ? "Create Goal" : "Next"
    }

    private var primaryButtonEnabled: Bool {
        switch step {
        case .type: return selectedType != nil
        case .basics: return !name.trimmingCharacters(in: .whitespaces).isEmpty && Double(amountText) != nil
        case .advanced: return true
        }
    }

    private func primaryAction() {
        switch step {
        case .type:
            withAnimation { step = .basics }
        case .basics:
            withAnimation { step = .advanced }
        case .advanced:
            createGoal()
        }
    }

    private func createGoal() {
        guard let type = selectedType, let amount = Double(amountText) else { return }
        let goal = Goal(
            name: name,
            type: type,
            targetAmount: amount,
            targetDate: hasTargetDate ? targetDate : nil,
            monthlyContribution: Double(monthlyContributionText),
            interestRate: Double(interestRateText),
            monthlyPayment: Double(monthlyPaymentText)
        )
        onCreate(goal)
        dismiss()
    }
}

#Preview {
    AddGoalView(onCreate: { _ in })
}
