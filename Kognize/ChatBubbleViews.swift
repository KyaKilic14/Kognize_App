//
//  ChatBubbleViews.swift
//  Kognize
//
//  Shared chat-bubble UI used by Ask Kog and Portfolio Breakdown's canned
//  Q&A step. No AI behind either — just the bubble/typing-indicator UI.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 40) }

            Text(message.text)
                .font(.subheadline)
                .foregroundStyle(message.isFromUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(message.isFromUser ? Color.kognizePurple : Color.primary.opacity(0.1))
                )

            if !message.isFromUser { Spacer(minLength: 40) }
        }
    }
}

struct TypingBubble: View {
    @State private var isAnimating = false

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.primary.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .offset(y: isAnimating ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.4).repeatForever().delay(Double(index) * 0.15),
                            value: isAnimating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.1)))

            Spacer(minLength: 40)
        }
        .onAppear { isAnimating = true }
    }
}
