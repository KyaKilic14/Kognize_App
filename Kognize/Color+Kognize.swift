//
//  Color+Kognize.swift
//  Kognize
//
//  kognizeBackground adapts to the active color scheme automatically.
//  kognizePurple is no longer a fixed constant -- it reads live from
//  ThemeManager, so every existing call site updates the instant the
//  accent changes, with no per-screen code.
//

import SwiftUI
import UIKit

extension Color {
    static let kognizeBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    })

    static var kognizePurple: Color { ThemeManager.shared.accentColor }

    static let kognizePurpleDeep = Color(red: 0.353, green: 0.094, blue: 0.604)
}
