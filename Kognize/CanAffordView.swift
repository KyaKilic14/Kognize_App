//
//  CanAffordView.swift
//  Kognize
//
//  Answers one specific question -- "how comfortably does this amount fit
//  your current money and goals" -- never "should you buy this." The score
//  is a transparent average of four factors, always shown alongside the
//  number, never a bare digit. No advisory language ("should"/"worth it"/
//  "good idea") anywhere in this file, including for investment-framed
//  purchases -- see the compliance note in the plan this was built from.
//

import SwiftUI

private enum CanAffordStep {
    case form
    case result
}

struct CanAffordView: View {
    @State private var step: CanAffordStep = .form
    @State private var amountText = ""
    @State private var itemName = ""
    @State private var whyText = ""
    @State private var intent: PurchaseIntent = .enjoyment
    @State private var result: AffordabilityResult?

    var body: some View {
        Group {
            switch step {
            case .form:
                formStep
            case .result:
                if let result {
                    resultStep(result)
                }
            }
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Can I Afford This?")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Form

    private var formStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What are you thinking of buying?")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("Kog will show how this fits your current income, cash, and goals — it's a budget check, not a recommendation.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }

                labeledField(title: "Amount (£)", text: $amountText, keyboard: .decimalPad)
                labeledField(title: "What is it?", text: $itemName)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why do you want it?")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    TextField("Tell Kog a bit about it", text: $whyText, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("How would you frame this?")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    Picker("Intent", selection: $intent) {
                        ForEach(PurchaseIntent.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Button {
                    check()
                } label: {
                    Text("Check")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .disabled(Double(amountText) == nil || itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || whyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(24)
        }
    }

    private func labeledField(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
            TextField(title, text: text)
                .keyboardType(keyboard)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Result

    private func resultStep(_ result: AffordabilityResult) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "cart.badge.questionmark")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.kognizePurple)
                    Text("\(result.overallScore)/10")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Affordability comfort")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles").foregroundStyle(Color.kognizePurple)
                        Text("Kog's take").font(.headline).foregroundStyle(.primary)
                    }
                    Text(result.summary)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .padding(20)
                .background(widgetCardBackground())

                VStack(alignment: .leading, spacing: 14) {
                    Text("How this was worked out")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    ForEach(result.factors, id: \.label) { factor in
                        factorRow(factor)
                    }
                }
                .padding(20)
                .background(widgetCardBackground())

                if !whyText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What you told Kog")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("\"\(whyText)\"")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .italic()
                    }
                    .padding(20)
                    .background(widgetCardBackground())
                }

                Button {
                    resetFlow()
                } label: {
                    Text("Check Another")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
        }
    }

    private func factorRow(_ factor: AffordabilityFactor) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(factor.label)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(factor.score)/10")
                    .font(.subheadline.bold())
                    .foregroundStyle(factor.score >= 7 ? Color.kognizePurple : (factor.score >= 4 ? .primary : Color.red.opacity(0.85)))
            }
            Text(factor.explanation)
                .font(.footnote)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Scoring engine

    private func check() {
        let amount = Double(amountText) ?? 0
        let factors = [
            incomeFitFactor(amount: amount),
            cashBufferFactor(amount: amount),
            goalImpactFactor(amount: amount),
            proportionalityFactor(amount: amount)
        ]
        let overall = Int((Double(factors.map(\.score).reduce(0, +)) / Double(factors.count)).rounded())
        let summary = buildSummary(factors: factors)

        result = AffordabilityResult(overallScore: overall, factors: factors, summary: summary)
        saveToHistory(amount: amount, overallScore: overall, summary: summary)
        withAnimation { step = .result }
    }

    private func incomeFitFactor(amount: Double) -> AffordabilityFactor {
        let headroom = max(FinanceStore.shared.incomeTotal - FinanceStore.shared.spendingTotal, 0)
        guard headroom > 0 else {
            return AffordabilityFactor(label: "Disposable income fit", score: 2, explanation: "Your typical monthly spending currently uses all of your income, leaving little headroom.")
        }
        let ratio = amount / headroom
        let score: Int
        switch ratio {
        case ..<0.3: score = 10
        case 0.3..<0.7: score = 7
        case 0.7..<1.0: score = 4
        default: score = 1
        }
        let explanation = "This would use about \(Int((ratio * 100).rounded()))% of your typical \(formattedGBP(headroom)) monthly headroom."
        return AffordabilityFactor(label: "Disposable income fit", score: score, explanation: explanation)
    }

    private func cashBufferFactor(amount: Double) -> AffordabilityFactor {
        let cash = FinanceStore.shared.cashTotal
        guard cash > 0 else {
            return AffordabilityFactor(label: "Cash buffer impact", score: 1, explanation: "No cash balance is currently tracked.")
        }
        let remaining = cash - amount
        let ratio = remaining / cash
        let score: Int
        switch ratio {
        case 0.7...: score = 10
        case 0.4..<0.7: score = 7
        case 0.1..<0.4: score = 4
        default: score = 1
        }
        let explanation = remaining >= 0
            ? "Leaves \(formattedGBP(remaining)) of your \(formattedGBP(cash)) cash balance."
            : "This exceeds your current cash balance of \(formattedGBP(cash))."
        return AffordabilityFactor(label: "Cash buffer impact", score: score, explanation: explanation)
    }

    private func goalImpactFactor(amount: Double) -> AffordabilityFactor {
        let fundedGoals = GoalsStore.shared.goals.filter { ($0.monthlyContribution ?? 0) > 0 }
        guard !fundedGoals.isEmpty else {
            return AffordabilityFactor(label: "Goal impact", score: 10, explanation: "No active goals with a monthly contribution are being tracked yet.")
        }
        let totalMonthlyContribution = fundedGoals.reduce(0) { $0 + ($1.monthlyContribution ?? 0) }
        let ratio = totalMonthlyContribution > 0 ? amount / totalMonthlyContribution : 0
        let score: Int
        switch ratio {
        case ..<0.5: score = 10
        case 0.5..<1.5: score = 6
        case 1.5..<3: score = 3
        default: score = 1
        }
        let goalNames = fundedGoals.map(\.name).joined(separator: ", ")
        let explanation = "Roughly \(Int((ratio * 100).rounded()))% of a month's combined contribution toward \(goalNames)."
        return AffordabilityFactor(label: "Goal impact", score: score, explanation: explanation)
    }

    private func proportionalityFactor(amount: Double) -> AffordabilityFactor {
        let typicalSpend = FinanceStore.shared.spendingTotal
        guard typicalSpend > 0 else {
            return AffordabilityFactor(label: "Proportionality", score: 5, explanation: "No typical spending baseline is tracked yet.")
        }
        let ratio = amount / typicalSpend
        let score: Int
        switch ratio {
        case ..<0.1: score = 10
        case 0.1..<0.3: score = 8
        case 0.3..<0.6: score = 5
        default: score = 2
        }
        let explanation = "This is about \(Int((ratio * 100).rounded()))% of your typical \(formattedGBP(typicalSpend)) monthly spending."
        return AffordabilityFactor(label: "Proportionality", score: score, explanation: explanation)
    }

    /// Descriptive only -- names whichever factor is tightest, never tells
    /// the user what to do. Investment-framed purchases get an explicit
    /// note that the score is a budget-fit check, not a comment on the
    /// purchase's merit.
    private func buildSummary(factors: [AffordabilityFactor]) -> String {
        var summary: String
        if let lowest = factors.min(by: { $0.score < $1.score }), lowest.score <= 4 {
            summary = "This fits your overall budget, though \(lowest.label.lowercased()) is the main thing to be aware of — \(lowest.explanation)"
        } else {
            summary = "This comfortably fits your current income, cash, and goals."
        }
        if intent == .investment {
            summary += " This score reflects how the amount fits your budget and goal timelines only — it isn't a comment on the investment itself."
        }
        return summary
    }

    // MARK: - Save + Reset

    private func saveToHistory(amount: Double, overallScore: Int, summary: String) {
        let entry = HistoryEntry(
            date: Date(),
            title: "\(itemName) — \(formattedGBP(amount))",
            content: .affordabilityCheck(
                item: itemName,
                amount: amount,
                intent: intent.rawValue,
                score: overallScore,
                summary: summary
            )
        )
        HistoryStore.shared.save(entry)
    }

    private func resetFlow() {
        step = .form
        amountText = ""
        itemName = ""
        whyText = ""
        intent = .enjoyment
        result = nil
    }
}

#Preview {
    NavigationStack {
        CanAffordView()
    }
}
