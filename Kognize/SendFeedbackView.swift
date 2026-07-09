//
//  SendFeedbackView.swift
//  Kognize
//
//  Frontend-only: there's no admin website/feedback board to submit to
//  yet (master plan section 10), so this just confirms locally. The real
//  submit-to-backend call is a later build step.
//

import SwiftUI

private enum FeedbackCategory: String, CaseIterable, Identifiable {
    case bug = "Bug"
    case featureRequest = "Feature Request"
    case general = "General Feedback"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bug: return "ladybug"
        case .featureRequest: return "lightbulb"
        case .general: return "bubble.left.and.exclamationmark.bubble.right"
        }
    }
}

struct SendFeedbackView: View {
    @State private var category: FeedbackCategory = .general
    @State private var message = ""
    @State private var didSubmit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Send Feedback")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    Text("Tell us what's working, what's not, or what you'd like to see.")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Category")
                        .font(.caption)
                        .foregroundStyle(.primary)

                    HStack(spacing: 10) {
                        ForEach(FeedbackCategory.allCases) { option in
                            categoryButton(option)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Details")
                        .font(.caption)
                        .foregroundStyle(.primary)

                    TextField("What's on your mind?", text: $message, axis: .vertical)
                        .lineLimit(6...12)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.06)))
                        .foregroundStyle(.primary)
                }

                Button(action: submit) {
                    Text(didSubmit ? "Sent — thank you!" : "Send Feedback")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.kognizePurple.opacity(0.3) : Color.kognizePurple)
                        )
                }
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if didSubmit {
                    Text("This doesn't reach a real team yet — the feedback board is a later build step.")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
            .padding(20)
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Send Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func categoryButton(_ option: FeedbackCategory) -> some View {
        let isSelected = category == option
        return Button {
            category = option
            didSubmit = false
        } label: {
            VStack(spacing: 6) {
                Image(systemName: option.icon)
                    .font(.system(size: 18, weight: .medium))
                Text(option.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(isSelected ? Color.kognizePurple : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primary.opacity(isSelected ? 0.1 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? Color.kognizePurple : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func submit() {
        didSubmit = true
    }
}

#Preview {
    NavigationStack {
        SendFeedbackView()
    }
}
