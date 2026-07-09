//
//  Goal.swift
//  Kognize
//
//  Frontend-only model — goals live in memory only until a persistence
//  layer exists.
//

import Foundation

enum GoalType: String, CaseIterable, Identifiable {
    case savings = "Savings"
    case debtReduction = "Debt Reduction"
    case emergencyFund = "Emergency Fund"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .savings: return "banknote"
        case .debtReduction: return "creditcard.trianglebadge.exclamationmark"
        case .emergencyFund: return "shield.lefthalf.filled"
        }
    }
}

struct Goal: Identifiable {
    let id = UUID()
    var name: String
    var type: GoalType
    var targetAmount: Double
    var currentAmount: Double = 0
    var targetDate: Date?
    var monthlyContribution: Double?
    var interestRate: Double?
    var monthlyPayment: Double?

    var hasAdvancedDetails: Bool {
        targetDate != nil || monthlyContribution != nil || interestRate != nil || monthlyPayment != nil
    }
}
