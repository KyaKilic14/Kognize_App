//
//  TransactionsView.swift
//  Kognize
//
//  Kog proactively asks about uncategorized transactions, learns from the
//  answers (TransactionsStore.learnRule), then auto-sorts future matches
//  without asking -- always surfaced via a dismissible banner with a
//  "Return to normal" undo, never applied silently. Sorting a transaction
//  into Subscriptions offers (never forces) adding it to Subscription
//  Centre too, guarded against duplicates by merchant name.
//

import SwiftUI

struct TransactionsView: View {
    @State private var pendingQuestion: Transaction?
    @State private var activeBanner: Transaction?
    @State private var subscriptionOffer: Transaction?
    @State private var skippedIDs: Set<UUID> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let pendingQuestion {
                    questionCard(for: pendingQuestion)
                }

                if let subscriptionOffer {
                    subscriptionOfferCard(for: subscriptionOffer)
                }

                transactionList
            }
            .padding(20)
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    simulateTransaction()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.kognizePurple)
                }
                .accessibilityLabel("Simulate Transaction")
            }
        }
        .overlay(alignment: .top) {
            if let activeBanner {
                autoSortBanner(for: activeBanner)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            advanceToNextQuestion()
        }
    }

    // MARK: - Proactive question

    private func questionCard(for transaction: Transaction) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.kognizePurple)
                Text("Kog is asking")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Text("I see a payment of \(formattedGBP(transaction.amount)) to \(transaction.merchantName) — what should I sort this as?")
                .font(.subheadline)
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                ForEach(TransactionCategory.allCases) { category in
                    Button {
                        answer(category)
                    } label: {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundStyle(Color.kognizePurple)
                                .frame(width: 24)
                            Text(category.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.05)))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button("Skip for now") {
                skip()
            }
            .font(.footnote)
            .foregroundStyle(.primary)
        }
        .padding(18)
        .background(widgetCardBackground())
    }

    // MARK: - Auto-sort banner

    private func autoSortBanner(for transaction: Transaction) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.kognizePurple)

            VStack(alignment: .leading, spacing: 6) {
                Text("Kog sorted \(transaction.merchantName) into \(transaction.category?.rawValue ?? "a category") based on your past answers.")
                    .font(.footnote)
                    .foregroundStyle(.primary)

                Button("Return to normal") {
                    undoBanner()
                }
                .font(.footnote.bold())
                .foregroundStyle(Color.kognizePurple)
            }

            Spacer()

            Button {
                dismissBannerNaturally()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.primary.opacity(0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.kognizeBackground)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        )
    }

    // MARK: - Subscription offer

    private func subscriptionOfferCard(for transaction: Transaction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Color.kognizePurple)
                Text("This looks like a subscription")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Text("Add \(transaction.merchantName) to Subscription Centre so it's tracked alongside your other subscriptions?")
                .font(.subheadline)
                .foregroundStyle(.primary)

            HStack(spacing: 10) {
                Button {
                    addToSubscriptionCentre()
                } label: {
                    Text("Add")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.kognizePurple))
                }

                Button {
                    dismissSubscriptionOffer()
                } label: {
                    Text("Not now")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                }
            }
        }
        .padding(18)
        .background(widgetCardBackground())
    }

    // MARK: - Transaction list

    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Transactions")
                .font(.headline)
                .foregroundStyle(.primary)

            ForEach(TransactionsStore.shared.transactions) { transaction in
                transactionRow(transaction)
            }
        }
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 14) {
            Image(systemName: transaction.category?.icon ?? "questionmark.circle")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.kognizePurple)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchantName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                HStack(spacing: 6) {
                    Text(transaction.category?.rawValue ?? "Uncategorized")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                    if transaction.wasAutoSorted {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundStyle(Color.kognizePurple)
                    }
                }
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text((transaction.direction == .income ? "+" : "-") + formattedGBP(transaction.amount))
                .font(.subheadline.bold())
                .foregroundStyle(transaction.direction == .income ? Color.kognizePurple : .primary)
        }
        .padding(16)
        .background(widgetCardBackground())
    }

    // MARK: - State machine

    private func advanceToNextQuestion() {
        guard pendingQuestion == nil else { return }
        pendingQuestion = TransactionsStore.shared.uncategorized.first { !skippedIDs.contains($0.id) }
    }

    private func skip() {
        guard let transaction = pendingQuestion else { return }
        skippedIDs.insert(transaction.id)
        pendingQuestion = nil
        advanceToNextQuestion()
    }

    @discardableResult
    private func apply(category: TransactionCategory, to transaction: Transaction, autoSorted: Bool) -> Transaction {
        guard let index = TransactionsStore.shared.transactions.firstIndex(where: { $0.id == transaction.id }) else {
            return transaction
        }
        TransactionsStore.shared.transactions[index].category = category
        TransactionsStore.shared.transactions[index].wasAutoSorted = autoSorted
        return TransactionsStore.shared.transactions[index]
    }

    private func answer(_ category: TransactionCategory) {
        guard let transaction = pendingQuestion else { return }
        let updated = apply(category: category, to: transaction, autoSorted: false)
        TransactionsStore.shared.learnRule(merchantName: transaction.merchantName, category: category)
        pendingQuestion = nil
        completeCategorization(for: updated, thenAdvanceQuestion: true)
    }

    private func simulateTransaction() {
        let transaction = TransactionsStore.shared.simulateNewTransaction()
        if transaction.wasAutoSorted {
            withAnimation { activeBanner = transaction }
            scheduleBannerDismiss(for: transaction.id)
        } else {
            advanceToNextQuestion()
        }
    }

    private func scheduleBannerDismiss(for id: UUID) {
        Task {
            try? await Task.sleep(for: .seconds(5))
            if activeBanner?.id == id {
                dismissBannerNaturally()
            }
        }
    }

    private func dismissBannerNaturally() {
        guard let transaction = activeBanner else { return }
        withAnimation { activeBanner = nil }
        completeCategorization(for: transaction, thenAdvanceQuestion: false)
    }

    /// Reverts the specific transaction back to uncategorized -- the
    /// learned rule itself is left untouched, so this undoes the action,
    /// not what Kog has learned.
    private func undoBanner() {
        guard let transaction = activeBanner else { return }
        if let index = TransactionsStore.shared.transactions.firstIndex(where: { $0.id == transaction.id }) {
            TransactionsStore.shared.transactions[index].category = nil
            TransactionsStore.shared.transactions[index].wasAutoSorted = false
        }
        withAnimation { activeBanner = nil }
        advanceToNextQuestion()
    }

    private func completeCategorization(for transaction: Transaction, thenAdvanceQuestion: Bool) {
        if shouldOfferSubscription(transaction) {
            subscriptionOffer = transaction
        } else if thenAdvanceQuestion {
            advanceToNextQuestion()
        }
    }

    private func shouldOfferSubscription(_ transaction: Transaction) -> Bool {
        guard transaction.category == .subscriptions else { return false }
        return !SubscriptionStore.shared.subscriptions.contains {
            $0.name.caseInsensitiveCompare(transaction.merchantName) == .orderedSame
        }
    }

    private func addToSubscriptionCentre() {
        guard let transaction = subscriptionOffer else { return }

        SubscriptionStore.shared.subscriptions.append(
            Subscription(name: transaction.merchantName, cost: transaction.amount, frequency: .monthly)
        )
        FinanceStore.shared.recordSubscription(cost: transaction.amount, frequency: .monthly)

        let entry = HistoryEntry(
            date: Date(),
            title: "\(transaction.merchantName) — \(formattedGBP(transaction.amount))/Monthly",
            content: .subscriptionCentre(
                name: transaction.merchantName,
                cost: transaction.amount,
                frequency: SubscriptionFrequency.monthly.rawValue,
                messages: []
            )
        )
        HistoryStore.shared.save(entry)

        subscriptionOffer = nil
        advanceToNextQuestion()
    }

    private func dismissSubscriptionOffer() {
        subscriptionOffer = nil
        advanceToNextQuestion()
    }
}

#Preview {
    NavigationStack {
        TransactionsView()
    }
}
