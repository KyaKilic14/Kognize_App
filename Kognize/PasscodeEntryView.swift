//
//  PasscodeEntryView.swift
//  Kognize
//
//  Frontend-only for now: passcode is hardcoded and nothing is persisted.
//  Once we build storage, this should read/write the Keychain (on-device,
//  encrypted) — never a backend call, an app-unlock code never needs to
//  leave the device.
//

import SwiftUI

struct PasscodeEntryView: View {
    let onSuccess: () -> Void
    let onUseFaceIDInstead: () -> Void

    private let correctPasscode = [1, 2, 3, 4]

    @State private var enteredDigits: [Int] = []
    @State private var shuffledDigits: [Int] = Array(0...9).shuffled()
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Enter Passcode")
                .font(.title2.bold())
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < enteredDigits.count ? Color.white : Color.clear)
                        .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1.5))
                        .frame(width: 14, height: 14)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red.opacity(0.9))
            }

            Spacer()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(shuffledDigits, id: \.self) { digit in
                    Button {
                        append(digit)
                    } label: {
                        Text("\(digit)")
                            .font(.title.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Circle().fill(.white.opacity(0.08)))
                    }
                }
            }
            .padding(.horizontal, 40)

            Button("Delete") {
                if !enteredDigits.isEmpty {
                    enteredDigits.removeLast()
                }
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.7))
            .disabled(enteredDigits.isEmpty)
            .padding(.top, 8)

            Button("Use Face ID Instead", action: onUseFaceIDInstead)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea())
    }

    private func append(_ digit: Int) {
        guard enteredDigits.count < 4 else { return }
        errorMessage = nil
        enteredDigits.append(digit)

        guard enteredDigits.count == 4 else { return }

        if enteredDigits == correctPasscode {
            onSuccess()
        } else {
            errorMessage = "Incorrect passcode"
            enteredDigits = []
            shuffledDigits = Array(0...9).shuffled()
        }
    }
}

#Preview {
    PasscodeEntryView(onSuccess: {}, onUseFaceIDInstead: {})
}
