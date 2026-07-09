//
//  ThemeManager.swift
//  Kognize
//
//  Single source of truth for the accent color and light/dark/system
//  appearance choice. Persisted locally (UserDefaults) — this is app
//  preference, not financial data, so it doesn't need Keychain-grade
//  handling.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct AccentOption: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    static let accentOptions: [AccentOption] = [
        AccentOption(name: "Electric Purple", color: Color(red: 0.616, green: 0.306, blue: 0.867)),
        AccentOption(name: "Ocean Blue", color: Color(red: 0.2, green: 0.5, blue: 0.9)),
        AccentOption(name: "Emerald", color: Color(red: 0.2, green: 0.7, blue: 0.5)),
        AccentOption(name: "Sunset Orange", color: Color(red: 0.95, green: 0.5, blue: 0.2)),
        AccentOption(name: "Rose", color: Color(red: 0.9, green: 0.3, blue: 0.5))
    ]

    var accentName: String {
        didSet { UserDefaults.standard.set(accentName, forKey: "kognize.accentName") }
    }

    var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: "kognize.appearanceMode") }
    }

    var accentColor: Color {
        Self.accentOptions.first(where: { $0.name == accentName })?.color ?? Self.accentOptions[0].color
    }

    private init() {
        accentName = UserDefaults.standard.string(forKey: "kognize.accentName") ?? "Electric Purple"
        let storedMode = UserDefaults.standard.string(forKey: "kognize.appearanceMode") ?? AppearanceMode.dark.rawValue
        appearanceMode = AppearanceMode(rawValue: storedMode) ?? .dark
    }
}
