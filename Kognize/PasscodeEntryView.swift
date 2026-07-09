//
//  PasscodeEntryView.swift
//  Kognize
//
//  Frontend-only for now: passcode is hardcoded and nothing is persisted.
//  Once we build storage, this should read/write a salted hash via the
//  Keychain (on-device, encrypted) — never a backend call, and never the
//  raw digits at rest. See CLAUDE.md for the full security rationale.
//

import SwiftUI

private enum KeypadKey: Hashable {
    case digit(Int)
    case delete
    case enter
}

enum PasscodeFeedback {
    case correct
    case incorrect

    var color: Color {
        switch self {
        case .correct: return .green
        case .incorrect: return .red
        }
    }
}

struct PasscodeEntryView: View {
    let onSuccess: () -> Void
    @Binding var feedback: PasscodeFeedback?

    private let correctPasscode = [1, 2, 3, 4]

    @State private var enteredDigits: [Int] = []
    @State private var keypadLayout: [KeypadKey] = Self.shuffledLayout()

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("Enter Passcode")
                .font(.title2.bold())
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(dotColor(at: index))
                        .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1.5))
                        .shadow(color: feedback?.color ?? .clear, radius: 6)
                        .frame(width: 14, height: 14)
                }
            }

            Spacer()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(Array(keypadLayout.enumerated()), id: \.offset) { _, key in
                    keypadButton(for: key)
                }
            }
            .padding(.horizontal, 40)
            .disabled(feedback != nil)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: feedback != nil)
    }

    @ViewBuilder
    private func keypadButton(for key: KeypadKey) -> some View {
        switch key {
        case .digit(let digit):
            Button {
                append(digit)
            } label: {
                Text("\(digit)")
                    .font(.title.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Circle().fill(.white.opacity(0.08)))
            }

        case .delete:
            Button {
                if !enteredDigits.isEmpty {
                    enteredDigits.removeLast()
                }
            } label: {
                Image(systemName: "delete.left")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 72, height: 72)
            }
            .disabled(enteredDigits.isEmpty)

        case .enter:
            Button(action: submit) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(enteredDigits.count == 4 ? .white : .white.opacity(0.25))
                    .frame(width: 72, height: 72)
            }
            .disabled(enteredDigits.count != 4)
        }
    }

    private func dotColor(at index: Int) -> Color {
        if let feedback {
            return feedback.color
        }
        return index < enteredDigits.count ? .white : .clear
    }

    private func append(_ digit: Int) {
        guard enteredDigits.count < 4 else { return }
        enteredDigits.append(digit)
    }

    private func submit() {
        guard enteredDigits.count == 4, feedback == nil else { return }

        let isCorrect = enteredDigits == correctPasscode
        feedback = isCorrect ? .correct : .incorrect

        Task {
            try? await Task.sleep(for: .milliseconds(500))
            if isCorrect {
                onSuccess()
            } else {
                feedback = nil
                enteredDigits = []
                keypadLayout = Self.shuffledLayout()
            }
        }
    }

    /// 10 digits + delete + enter = 12 items, exactly filling a 3x4 grid.
    /// Delete always lands bottom-left (index 9), enter always bottom-right
    /// (index 11); the 10 digits fill every other slot in random order.
    private static func shuffledLayout() -> [KeypadKey] {
        var digits = Array(0...9).shuffled().map(KeypadKey.digit)
        var layout: [KeypadKey] = []
        layout.reserveCapacity(12)

        for position in 0..<12 {
            switch position {
            case 9:
                layout.append(.delete)
            case 11:
                layout.append(.enter)
            default:
                layout.append(digits.removeFirst())
            }
        }

        return layout
    }
}

private struct PasscodeEntryPreviewContainer: View {
    @State private var feedback: PasscodeFeedback?

    var body: some View {
        PasscodeEntryView(onSuccess: {}, feedback: $feedback)
    }
}

#Preview {
    PasscodeEntryPreviewContainer()
}
