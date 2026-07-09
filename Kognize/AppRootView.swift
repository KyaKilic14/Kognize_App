//
//  AppRootView.swift
//  Kognize
//

import SwiftUI

private enum AppStage {
    case disclaimer
    case authenticating
    case dashboard
}

struct AppRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var stage: AppStage = .disclaimer
    @State private var showPrivacyOverlay = false

    var body: some View {
        ZStack {
            switch stage {
            case .disclaimer:
                DisclaimerView {
                    stage = .authenticating
                }
            case .authenticating:
                FaceIDGateView {
                    stage = .dashboard
                }
            case .dashboard:
                MainTabView {
                    stage = .disclaimer
                }
            }

            if showPrivacyOverlay {
                PrivacyOverlay()
            }
        }
        .preferredColorScheme(ThemeManager.shared.appearanceMode.colorScheme)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                showPrivacyOverlay = false
            case .inactive:
                showPrivacyOverlay = true
            case .background:
                showPrivacyOverlay = true
                // Leaving the foreground counts as "closing" the app for
                // privacy purposes: require the disclaimer + Face ID again
                // on return, not just on cold launch.
                stage = .disclaimer
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    AppRootView()
}
