//
//  FaceIDGateView.swift
//  Kognize
//

import SwiftUI
import LocalAuthentication

struct FaceIDGateView: View {
    let onSuccess: () -> Void

    @State private var errorMessage: String?
    @State private var isAuthenticating = false
    @State private var isShowingPasscodeEntry = false

    var body: some View {
        Group {
            if isShowingPasscodeEntry {
                PasscodeEntryView(onSuccess: onSuccess) {
                    isShowingPasscodeEntry = false
                }
            } else {
                biometricPrompt
            }
        }
    }

    private var biometricPrompt: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "faceid")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))

            Text("Unlock Kognize")
                .font(.title2.bold())
                .foregroundStyle(.white)

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: authenticate) {
                    Text(isAuthenticating ? "Checking…" : "Try Again")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isAuthenticating)

                Button("Use Passcode Instead") {
                    isShowingPasscodeEntry = true
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea())
        .onAppear(perform: authenticate)
    }

    private func authenticate() {
        let context = LAContext()
        var evaluationError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &evaluationError) else {
            errorMessage = "Face ID or passcode isn't set up on this device. Use the app passcode instead."
            return
        }

        isAuthenticating = true
        errorMessage = nil

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock Kognize to view your financial data."
        ) { success, _ in
            DispatchQueue.main.async {
                isAuthenticating = false
                if success {
                    onSuccess()
                } else {
                    errorMessage = "Authentication failed. Try again or use your passcode."
                }
            }
        }
    }
}

#Preview {
    FaceIDGateView(onSuccess: {})
}
