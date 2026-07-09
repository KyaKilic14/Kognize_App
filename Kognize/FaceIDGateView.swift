//
//  FaceIDGateView.swift
//  Kognize
//
//  Passcode is the primary, always-visible unlock method. Face ID attempts
//  automatically in the background as soon as this screen appears — no
//  button press required — represented by a small status icon near the
//  top of the screen. Biometrics-only policy on purpose: it must never
//  trigger iOS's own system passcode sheet, which would fight with our
//  custom keypad below it.
//

import SwiftUI
import LocalAuthentication

private enum FaceIDStatus {
    case idle
    case checking
    case failed
    case unavailable
}

struct FaceIDGateView: View {
    let onSuccess: () -> Void

    @State private var faceIDStatus: FaceIDStatus = .idle

    var body: some View {
        VStack(spacing: 0) {
            faceIDIndicator
                .padding(.top, 8)

            PasscodeEntryView(onSuccess: onSuccess)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea())
        .onAppear(perform: attemptFaceID)
    }

    private var faceIDIndicator: some View {
        Button(action: attemptFaceID) {
            Image(systemName: "faceid")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(faceIDColor)
                .frame(width: 36, height: 36)
                .background(Circle().fill(.white.opacity(0.06)))
        }
        .disabled(faceIDStatus == .checking || faceIDStatus == .unavailable)
    }

    private var faceIDColor: Color {
        switch faceIDStatus {
        case .idle, .checking: return .white.opacity(0.6)
        case .failed: return .red.opacity(0.8)
        case .unavailable: return .white.opacity(0.15)
        }
    }

    private func attemptFaceID() {
        guard faceIDStatus != .checking else { return }

        let context = LAContext()
        var evaluationError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evaluationError) else {
            faceIDStatus = .unavailable
            return
        }

        faceIDStatus = .checking

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock Kognize to view your financial data."
        ) { success, _ in
            DispatchQueue.main.async {
                if success {
                    onSuccess()
                } else {
                    faceIDStatus = .failed
                }
            }
        }
    }
}

#Preview {
    FaceIDGateView(onSuccess: {})
}
