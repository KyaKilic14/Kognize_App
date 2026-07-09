//
//  Color+Kognize.swift
//  Kognize
//
//  kognizeBackground adapts to the active color scheme automatically.
//  kognizePurple and kognizeAccentDark are no longer fixed constants --
//  they read live from ThemeManager, so every existing call site updates
//  the instant the accent changes, with no per-screen code.
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

    /// A solid, slightly darker version of the current accent -- used
    /// where an icon needs to read clearly against its own translucent
    /// accent-tinted background, for any accent color, not just purple.
    static var kognizeAccentDark: Color { ThemeManager.shared.accentColor.darkened(by: 0.18) }

    func darkened(by amount: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        return Color(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(max(brightness - CGFloat(amount), 0)),
            opacity: Double(alpha)
        )
    }
}
