//
//  AskKogView.swift
//  Kognize
//
//  No AI connection yet — sending a message always replies with a static
//  placeholder after a simulated typing delay, so the bubble/animation UI
//  can be seen and reviewed before the Kog endpoint exists (Build order
//  steps 5 and 7).
//

import SwiftUI

private struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}

struct AskKogView: View {
    @State private var draftMessage = ""
    @State private var messages: [ChatMessage] = []
    @State private var isKogTyping = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if messages.isEmpty && !isKogTyping {
                    emptyState
                } else {
                    messageList
                }

                inputBar
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Ask Kog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "message.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color.kognizePurple)

                Text("Ask Kog")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Ask a question about your finances — always educational, never advice.")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if isKogTyping {
                        TypingBubble()
                            .id("typing")
                    }
                }
                .padding(16)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
            .onChange(of: isKogTyping) { _, typing in
                guard typing else { return }
                withAnimation {
                    proxy.scrollTo("typing", anchor: .bottom)
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask Kog anything...", text: $draftMessage)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                )

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(canSend ? Color.kognizePurple : Color.primary.opacity(0.2))
            }
            .disabled(!canSend)
        }
        .padding()
    }

    private var canSend: Bool {
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isKogTyping
    }

    private func send() {
        let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(text: text, isFromUser: true))
        draftMessage = ""
        isKogTyping = true

        Task {
            try? await Task.sleep(for: .milliseconds(1200))
            isKogTyping = false
            messages.append(ChatMessage(
                text: "Hello world! I'm Kog — once I'm connected to your real data, I'll answer questions like this one for real.",
                isFromUser: false
            ))
        }
    }
}

private struct ChatBubble: View {
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

private struct TypingBubble: View {
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

#Preview {
    AskKogView()
}
