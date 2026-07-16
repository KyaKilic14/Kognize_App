//
//  HistoryStore.swift
//  Kognize
//
//  Shared, in-memory (no persistence layer yet) store of past feature
//  results, read-only once saved. Currently fed by Portfolio Breakdown,
//  Ask Kog, and Receipt Scanner; the enum-based content shape means future
//  features can plug into the same store the same way, without changing
//  HistoryView itself.
//

import Foundation

enum HistoryEntryContent {
    case portfolioBreakdown(diversification: String, dividendEstimate: String, considerations: [String])
    case askKogConversation(messages: [ChatMessage])
    case receiptScanner(merchant: String, date: Date, amount: Double, category: String, messages: [ChatMessage])
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let content: HistoryEntryContent

    var featureLabel: String {
        switch content {
        case .portfolioBreakdown: return "Portfolio Breakdown"
        case .askKogConversation: return "Ask Kog"
        case .receiptScanner: return "Receipt Scanner"
        }
    }

    var icon: String {
        switch content {
        case .portfolioBreakdown: return "chart.pie.fill"
        case .askKogConversation: return "message.fill"
        case .receiptScanner: return "doc.text.viewfinder"
        }
    }
}

@Observable
final class HistoryStore {
    static let shared = HistoryStore()

    var entries: [HistoryEntry] = []

    private init() {}

    func save(_ entry: HistoryEntry) {
        entries.insert(entry, at: 0)
    }
}
