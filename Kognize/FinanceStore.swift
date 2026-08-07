//
//  FinanceStore.swift
//  Kognize
//
//  Shared, in-memory (no persistence yet) numbers behind Dashboard's
//  Spending/Income/Score widgets. Previously those were hardcoded literals
//  with nothing feeding them -- this makes them genuinely live across
//  screens, starting with Receipt Scanner. Still entirely illustrative
//  until a real backend/aggregator exists (Build order steps 3-5).
//

import Foundation

@Observable
final class FinanceStore {
    static let shared = FinanceStore()

    var spendingTotal: Double = 1240
    var incomeTotal: Double = 2850
    var score: Int = 82

    // Net worth components -- illustrative placeholders, same as everything
    // else here, until a real aggregator/backend exists.
    var cashTotal: Double = 1850
    var investmentsTotal: Double = 4120
    var manualAssetsTotal: Double = 0
    var liabilitiesTotal: Double = 0
    var netWorthAdjustments: Double = 0

    private init() {}

    var netWorth: Double {
        cashTotal + investmentsTotal + manualAssetsTotal - liabilitiesTotal + netWorthAdjustments
    }

    var band: String {
        switch score {
        case 70...: return "Healthy"
        case 40..<70: return "Watch"
        default: return "Strained"
        }
    }

    /// Illustrative placeholder logic only -- a real score comes from the
    /// Kog scoring endpoint (Build order step 5), not a fixed nudge.
    func recordReceipt(amount: Double) {
        spendingTotal += amount
        score = max(score - 1, 30)
    }

    /// Same illustrative-placeholder caveat as recordReceipt -- a one-way
    /// nudge fired once per new subscription, not a live recalculation, so
    /// editing/deleting a subscription later doesn't reverse it.
    func recordSubscription(cost: Double, frequency: SubscriptionFrequency) {
        spendingTotal += cost * frequency.monthlyMultiplier
        score = max(score - 1, 30)
    }

    /// Only called once a life event's rule checklist has been confirmed by
    /// the user -- pass a signed value (positive = increase, negative =
    /// decrease). See NetWorthDetailView's relevanceRules() for the
    /// rules-and-confirmation mechanic that decides whether this gets called.
    func applyLifeEventAdjustment(_ amount: Double) {
        netWorthAdjustments += amount
    }
}

func formattedGBP(_ value: Double) -> String {
    "£" + Int(value.rounded()).formatted(.number.grouping(.automatic))
}
