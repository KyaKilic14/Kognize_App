//
//  CreditScoreStore.swift
//  Kognize
//
//  Design/UI shell only -- no real TransUnion integration exists, and
//  isConnected is hardcoded false on purpose (Kya's explicit call: build
//  the working UI, don't connect it yet). Illustrative history/score are
//  static placeholders, same pattern as every other store in this app.
//  Distinct from FinanceStore.score (Kognize's own internal health
//  score) -- this is a separate concept, a third-party credit score.
//

import Foundation

struct CreditScoreSnapshot: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
}

@Observable
final class CreditScoreStore {
    static let shared = CreditScoreStore()

    let isConnected = false

    var currentScore: Int = 682

    /// Illustrative monthly snapshots, oldest first.
    var history: [CreditScoreSnapshot] = {
        let scores = [648, 655, 661, 668, 675, 682]
        return scores.enumerated().map { index, score in
            let monthsAgo = scores.count - 1 - index
            return CreditScoreSnapshot(
                date: Calendar.current.date(byAdding: .month, value: -monthsAgo, to: Date()) ?? Date(),
                score: score
            )
        }
    }()

    private init() {}

    /// Illustrative UK-credit-score-shaped bands -- approximate, not
    /// sourced from TransUnion's real published thresholds.
    var band: String {
        switch currentScore {
        case 628...: return "Excellent"
        case 604..<628: return "Good"
        case 566..<604: return "Fair"
        case 551..<566: return "Poor"
        default: return "Very Poor"
        }
    }

    /// Simple, transparent linear extrapolation from the two most recent
    /// snapshots -- not real forecasting. Always paired with hedging copy
    /// wherever it's shown; never a guarantee.
    var projectedRange: (low: Int, high: Int)? {
        guard history.count >= 2 else { return nil }
        let recent = history.suffix(2)
        guard let first = recent.first, let last = recent.last else { return nil }

        let monthlyChange = Double(last.score - first.score)
        let projected = Double(currentScore) + monthlyChange * 3
        let buffer = max(abs(monthlyChange) * 1.5, 5)

        let low = Int((projected - buffer).rounded())
        let high = Int((projected + buffer).rounded())
        return (low: min(low, high), high: max(low, high))
    }
}
