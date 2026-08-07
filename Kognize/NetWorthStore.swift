//
//  NetWorthStore.swift
//  Kognize
//
//  Shared, in-memory (no persistence yet) list of life events the user has
//  told Kog about (new business, new car, new house, etc.). Each event may
//  or may not end up adjusting FinanceStore's net worth figure -- see
//  NetWorthDetailView's relevanceRules() for the rules-and-confirmation
//  mechanic that decides that, and FinanceStore.applyLifeEventAdjustment
//  for where a confirmed change actually lands.
//

import Foundation

enum LifeEventCategory: String, CaseIterable, Identifiable {
    case newBusiness = "New business"
    case newCar = "New car"
    case newHouse = "New house / property"
    case inheritance = "Inheritance or windfall"
    case majorPurchase = "Major purchase"
    case newJob = "New job / income change"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .newBusiness: return "briefcase.fill"
        case .newCar: return "car.fill"
        case .newHouse: return "house.fill"
        case .inheritance: return "gift.fill"
        case .majorPurchase: return "cart.fill"
        case .newJob: return "person.badge.clock.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    /// Rule #1 input -- categories that typically represent a one-off
    /// balance-sheet change vs. ones that don't (a job change affects
    /// income flow over time, not a lump-sum asset/liability).
    var typicallyAffectsBalance: Bool {
        switch self {
        case .newBusiness, .newCar, .newHouse, .inheritance, .majorPurchase: return true
        case .newJob, .other: return false
        }
    }
}

struct LifeEvent: Identifiable {
    let id = UUID()
    let date: Date
    var category: LifeEventCategory
    var detail: String
    var amount: Double?
    var isIncrease: Bool
    var wasApplied: Bool
}

@Observable
final class NetWorthStore {
    static let shared = NetWorthStore()

    var lifeEvents: [LifeEvent] = []

    private init() {}
}
