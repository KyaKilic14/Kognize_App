//
//  AffordabilityCheck.swift
//  Kognize
//
//  Shapes for "Can I Afford This?" -- no dedicated store, each check is
//  computed live from FinanceStore/GoalsStore and the result is saved to
//  HistoryStore, same as every other feature's completed-result pattern.
//

import Foundation

enum PurchaseIntent: String, CaseIterable, Identifiable {
    case enjoyment = "Enjoyment"
    case investment = "Investment"
    case necessity = "Necessity"

    var id: String { rawValue }
}

struct AffordabilityFactor {
    let label: String
    let score: Int
    let explanation: String
}

struct AffordabilityResult {
    let overallScore: Int
    let factors: [AffordabilityFactor]
    let summary: String
}
