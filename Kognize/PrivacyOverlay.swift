//
//  PrivacyOverlay.swift
//  Kognize
//
//  Full-screen cover shown whenever the app isn't in the foreground, so the
//  iOS app switcher snapshot never shows real content — no exceptions, even
//  for placeholder screens.
//

import SwiftUI

struct PrivacyOverlay: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(systemName: "lock.fill")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

#Preview {
    PrivacyOverlay()
}
