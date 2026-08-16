//
//  GoalsStore.swift
//  Kognize
//
//  Shared, in-memory (no persistence yet) home for goals -- promoted out
//  of GoalsView's local @State so other features (starting with Can I
//  Afford This?) can read them, same @Observable singleton pattern as
//  FinanceStore/SubscriptionStore/NetWorthStore/TransactionsStore.
//

import Foundation

@Observable
final class GoalsStore {
    static let shared = GoalsStore()

    var goals: [Goal] = []

    private init() {}
}
