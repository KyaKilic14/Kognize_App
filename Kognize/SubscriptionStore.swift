//
//  SubscriptionStore.swift
//  Kognize
//
//  Shared, in-memory (no persistence yet) list of the user's recurring
//  subscriptions, backing Subscription Centre. Separate from FinanceStore
//  the same way HistoryStore is separate from FinanceStore -- each store
//  owns one concern; FinanceStore just holds the aggregate totals.
//

import Foundation

enum SubscriptionFrequency: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { rawValue }

    /// Normalizes any billing frequency to an equivalent monthly cost, for
    /// the overview screen's "~£X/month" summary figure.
    var monthlyMultiplier: Double {
        switch self {
        case .weekly: return 52.0 / 12.0
        case .monthly: return 1
        case .yearly: return 1.0 / 12.0
        }
    }
}

struct Subscription: Identifiable {
    let id = UUID()
    var name: String
    var cost: Double
    var frequency: SubscriptionFrequency
}

@Observable
final class SubscriptionStore {
    static let shared = SubscriptionStore()

    var subscriptions: [Subscription] = [
        Subscription(name: "Netflix", cost: 15.99, frequency: .monthly),
        Subscription(name: "Spotify", cost: 11.99, frequency: .monthly),
        Subscription(name: "Local Gym", cost: 34.99, frequency: .monthly)
    ]

    private init() {}

    var estimatedMonthlyCost: Double {
        subscriptions.reduce(0) { $0 + $1.cost * $1.frequency.monthlyMultiplier }
    }
}
