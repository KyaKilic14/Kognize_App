//
//  NetWorthDetailView.swift
//  Kognize
//
//  Pushed from the Dashboard's Net Worth card (bespoke detail view, same
//  pattern as AccountsDetailView -- too much custom content for the shared
//  WidgetDetailView template). Breakdown + progression are illustrative
//  placeholders, same caveat as everything in FinanceStore. Life events
//  are the one place in the app where Kog's "judgment" actually gates a
//  real change to a number -- see relevanceRules() below -- and even then
//  only after the user explicitly confirms.
//

import SwiftUI

struct NetWorthDetailView: View {
    @State private var isAddEventPresented = false

    private let deltas: [(label: String, value: Int)] = [
        ("1W", 40), ("1M", 210), ("3M", 560), ("6M", 1180)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headline
                breakdownCard
                progressionSection
                lifeEventsSection
            }
            .padding(.bottom, 20)
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Net Worth")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isAddEventPresented = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.kognizePurple)
                }
            }
        }
        .sheet(isPresented: $isAddEventPresented) {
            AddLifeEventView()
        }
    }

    // MARK: - Headline

    private var headline: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(Color.kognizePurple)
            Text(formattedGBP(FinanceStore.shared.netWorth))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
            Text("Net Worth")
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    // MARK: - Breakdown

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Breakdown")
                .font(.headline)
                .foregroundStyle(.primary)

            breakdownRow(label: "Cash", value: FinanceStore.shared.cashTotal)
            breakdownRow(label: "Investments", value: FinanceStore.shared.investmentsTotal)
            breakdownRow(label: "Manual entries", value: FinanceStore.shared.manualAssetsTotal)
            breakdownRow(label: "Liabilities", value: -FinanceStore.shared.liabilitiesTotal)

            if FinanceStore.shared.netWorthAdjustments != 0 {
                breakdownRow(label: "Life event adjustments", value: FinanceStore.shared.netWorthAdjustments)
            }
        }
        .padding(20)
        .background(widgetCardBackground())
        .padding(.horizontal, 20)
    }

    private func breakdownRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            Text((value < 0 ? "-" : "") + formattedGBP(abs(value)))
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Progression

    private var progressionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Progression")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)

            HStack(spacing: 10) {
                ForEach(deltas, id: \.label) { delta in
                    VStack(spacing: 4) {
                        Text(delta.label)
                            .font(.caption2)
                            .foregroundStyle(.primary)
                        Text(delta.value >= 0 ? "+\(formattedGBP(Double(delta.value)))" : formattedGBP(Double(delta.value)))
                            .font(.subheadline.bold())
                            .foregroundStyle(delta.value >= 0 ? Color.kognizePurple : Color.red.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.05)))
                }
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles").foregroundStyle(Color.kognizePurple)
                    Text("Kog's take").font(.headline).foregroundStyle(.primary)
                }
                Text("Net worth has trended upward over the last few months, consistent with regular saving and no major new debt. This is a general trend read, not a forecast.")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            .padding(20)
            .background(widgetCardBackground())
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Life Events

    private var lifeEventsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Life Events")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)

            if NetWorthStore.shared.lifeEvents.isEmpty {
                Text("Tell Kog about changes in your financial life — a new business, car, house, or anything else — using the + button above.")
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .padding(20)
                    .background(widgetCardBackground())
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(NetWorthStore.shared.lifeEvents) { event in
                        lifeEventRow(event)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func lifeEventRow(_ event: LifeEvent) -> some View {
        HStack(spacing: 14) {
            Image(systemName: event.category.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.kognizePurple)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.category.rawValue)
                    .font(.headline)
                    .foregroundStyle(.primary)
                if !event.detail.isEmpty {
                    Text(event.detail)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.primary)
            }

            Spacer()

            if event.wasApplied, let amount = event.amount {
                Text((event.isIncrease ? "+" : "-") + formattedGBP(amount))
                    .font(.subheadline.bold())
                    .foregroundStyle(event.isIncrease ? Color.kognizePurple : Color.red.opacity(0.85))
            } else {
                Text("Note only")
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.5))
            }
        }
        .padding(16)
        .background(widgetCardBackground())
    }
}

// MARK: - Add Life Event

private enum AddLifeEventStep {
    case form
    case confirmChange
    case savedAsNote
}

private struct AddLifeEventView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var step: AddLifeEventStep = .form
    @State private var category: LifeEventCategory = .newBusiness
    @State private var detail = ""
    @State private var amountText = ""
    @State private var isIncrease = true
    @State private var evaluatedRules: [(label: String, passed: Bool)] = []

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .form:
                    formStep
                case .confirmChange:
                    confirmChangeStep
                case .savedAsNote:
                    savedAsNoteStep
                }
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("New Life Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if step == .form {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .preferredColorScheme(ThemeManager.shared.appearanceMode.colorScheme)
    }

    // MARK: - Form

    private var formStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("What's changing?")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    Picker("Category", selection: $category) {
                        ForEach(LifeEventCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.kognizePurple)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell Kog more")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    TextField("e.g. Bought a used hatchback outright", text: $detail, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount (£) — optional")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    TextField("Leave blank if this is just a note", text: $amountText)
                        .keyboardType(.decimalPad)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                        .foregroundStyle(.primary)
                }

                if !amountText.isEmpty {
                    Picker("Effect", selection: $isIncrease) {
                        Text("Increase").tag(true)
                        Text("Decrease").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                Text("Kog checks a short list of rules to see whether this looks like something that should adjust your Net Worth — you'll always get the final say before anything changes.")
                    .font(.footnote)
                    .foregroundStyle(.primary)

                Button {
                    submitForm()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .disabled(detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(24)
        }
    }

    private func submitForm() {
        let amount = Double(amountText)
        evaluatedRules = relevanceRules(category: category, detail: detail, amount: amount)
        let passedCount = evaluatedRules.filter(\.passed).count

        if Double(passedCount) / Double(evaluatedRules.count) >= 0.7 {
            withAnimation { step = .confirmChange }
        } else {
            finalizeAndSave(applied: false)
            withAnimation { step = .savedAsNote }
        }
    }

    /// Four transparent checks -- 3 of 4 (75%) clears the "70% of rules"
    /// bar. No amount entered fails rules #2 and #3 automatically, capping
    /// at 2/4 (50%), so an amount-less event can never trigger a proposed
    /// change -- there's nothing to apply.
    private func relevanceRules(category: LifeEventCategory, detail: String, amount: Double?) -> [(label: String, passed: Bool)] {
        let recurringKeywords = ["monthly", "weekly", "subscription", "every month"]
        let looksRecurring = recurringKeywords.contains { detail.localizedCaseInsensitiveContains($0) }

        return [
            ("This type of event typically affects assets or liabilities", category.typicallyAffectsBalance),
            ("An amount was entered", amount != nil),
            ("The amount looks like a plausible one-off figure", (amount ?? 0) > 0),
            ("This reads as a one-time event, not a recurring cost", !looksRecurring)
        ]
    }

    // MARK: - Confirm Change

    private var confirmChangeStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.kognizePurple)
                    Text("Kog thinks this affects your Net Worth")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(evaluatedRules, id: \.label) { rule in
                        HStack(spacing: 10) {
                            Image(systemName: rule.passed ? "checkmark.circle.fill" : "xmark.circle")
                                .foregroundStyle(rule.passed ? Color.kognizePurple : Color.primary.opacity(0.3))
                            Text(rule.label)
                                .font(.footnote)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .padding(18)
                .background(widgetCardBackground())

                HStack {
                    Text("Proposed change")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text((isIncrease ? "+" : "-") + formattedGBP(Double(amountText) ?? 0))
                        .font(.title3.bold())
                        .foregroundStyle(isIncrease ? Color.kognizePurple : Color.red.opacity(0.85))
                }
                .padding(18)
                .background(widgetCardBackground())

                VStack(spacing: 10) {
                    Button {
                        finalizeAndSave(applied: true)
                        dismiss()
                    } label: {
                        Text("Apply to Net Worth")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                    }

                    Button {
                        finalizeAndSave(applied: false)
                        dismiss()
                    } label: {
                        Text("Save as note only")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.primary.opacity(0.08)))
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: - Saved as Note

    private var savedAsNoteStep: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "note.text")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(Color.kognizePurple)

            Text("Saved as a Note")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Kog didn't find enough signal here to adjust your Net Worth automatically, so this was saved as a note Kog can reference — your Net Worth figure hasn't changed.")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Save

    private func finalizeAndSave(applied: Bool) {
        let amount = Double(amountText)

        let event = LifeEvent(
            date: Date(),
            category: category,
            detail: detail,
            amount: amount,
            isIncrease: isIncrease,
            wasApplied: applied
        )
        NetWorthStore.shared.lifeEvents.insert(event, at: 0)

        if applied, let amount {
            FinanceStore.shared.applyLifeEventAdjustment(isIncrease ? amount : -amount)
        }

        let entry = HistoryEntry(
            date: Date(),
            title: "\(category.rawValue)\(detail.isEmpty ? "" : ": \(detail)")",
            content: .netWorthLifeEvent(
                category: category.rawValue,
                detail: detail,
                amount: amount,
                wasApplied: applied
            )
        )
        HistoryStore.shared.save(entry)
    }
}

#Preview {
    NavigationStack {
        NetWorthDetailView()
    }
}
