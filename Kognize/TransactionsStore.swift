//
//  TransactionsStore.swift
//  Kognize
//
//  Illustrative, in-memory-only transaction feed -- there's no real
//  aggregator integration yet (Build order step 3), so this exists purely
//  to give Smart Sorting something to categorize. Deliberately not wired
//  into FinanceStore.spendingTotal -- same "independent illustrative
//  nudge, not a reconciled ledger" pattern Receipt Scanner and
//  Subscription Centre already use.
//

import Foundation

enum TransactionDirection {
    case spending
    case income
}

enum TransactionCategory: String, CaseIterable, Identifiable {
    case subscriptions = "Subscriptions"
    case groceries = "Groceries"
    case dining = "Dining"
    case transport = "Transport"
    case shopping = "Shopping"
    case salary = "Salary"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .subscriptions: return "arrow.triangle.2.circlepath"
        case .groceries: return "cart.fill"
        case .dining: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .salary: return "banknote.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    let date: Date
    var merchantName: String
    var amount: Double
    var direction: TransactionDirection
    var category: TransactionCategory?
    var wasAutoSorted: Bool = false
}

struct SortingRule: Identifiable {
    let id = UUID()
    var merchantKeyword: String
    var category: TransactionCategory
    var confirmedCount: Int
}

@Observable
final class TransactionsStore {
    static let shared = TransactionsStore()

    var transactions: [Transaction] = [
        Transaction(date: Date().addingTimeInterval(-86400 * 32), merchantName: "Netflix", amount: 15.99, direction: .spending, category: .subscriptions, wasAutoSorted: true),
        Transaction(date: Date().addingTimeInterval(-86400 * 3), merchantName: "Employer Payroll", amount: 2400, direction: .income, category: .salary),
        Transaction(date: Date().addingTimeInterval(-86400 * 2), merchantName: "Tesco", amount: 42.10, direction: .spending, category: nil),
        Transaction(date: Date().addingTimeInterval(-86400), merchantName: "Spotify", amount: 11.99, direction: .spending, category: nil)
    ]

    var rules: [SortingRule] = [
        SortingRule(merchantKeyword: "netflix", category: .subscriptions, confirmedCount: 1)
    ]

    /// Pool for the "Simulate New Transaction" button -- a mix of merchants
    /// already seen (so a learned rule can fire) and new ones (so there's
    /// always something fresh for Kog to proactively ask about).
    private let simulationPool: [(merchant: String, amount: Double, direction: TransactionDirection)] = [
        ("Netflix", 15.99, .spending),
        ("Spotify", 11.99, .spending),
        ("Deliveroo", 22.40, .spending),
        ("Uber", 18.50, .spending),
        ("Employer Payroll", 2400, .income)
    ]
    private var simulationIndex = 0

    private init() {}

    var uncategorized: [Transaction] {
        transactions.filter { $0.category == nil }
    }

    func matchingRule(for transaction: Transaction) -> SortingRule? {
        rules.first { $0.merchantKeyword.caseInsensitiveCompare(transaction.merchantName) == .orderedSame }
    }

    /// The "pattern from past responses" Kya asked for -- deliberately
    /// simple and transparent (exact merchant-name match), same spirit as
    /// Subscription Centre's known-service keyword table.
    func learnRule(merchantName: String, category: TransactionCategory) {
        let keyword = merchantName.lowercased()
        if let index = rules.firstIndex(where: { $0.merchantKeyword == keyword }) {
            rules[index].category = category
            rules[index].confirmedCount += 1
        } else {
            rules.append(SortingRule(merchantKeyword: keyword, category: category, confirmedCount: 1))
        }
    }

    @discardableResult
    func simulateNewTransaction() -> Transaction {
        let next = simulationPool[simulationIndex % simulationPool.count]
        simulationIndex += 1

        var transaction = Transaction(date: Date(), merchantName: next.merchant, amount: next.amount, direction: next.direction)
        if let rule = matchingRule(for: transaction) {
            transaction.category = rule.category
            transaction.wasAutoSorted = true
        }
        transactions.insert(transaction, at: 0)
        return transaction
    }
}
