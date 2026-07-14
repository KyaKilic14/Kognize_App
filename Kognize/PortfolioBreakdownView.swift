//
//  PortfolioBreakdownView.swift
//  Kognize
//
//  UI shell only — no real image analysis or AI reasoning exists yet.
//  Matches Ask Kog's philosophy: real UI/flow, static canned output, wired
//  for a real backend later. All figures below are placeholder/illustrative.
//
//  Copy throughout stays descriptive, never advisory ("appears," "roughly,"
//  "worth being aware of" -- never "recommend," "you should," "sell,"
//  "buy") to match the app's non-negotiable "observes and explains, never
//  advises" principle.
//

import SwiftUI
import PhotosUI

private enum PortfolioStep: Int {
    case upload
    case conversation
    case results
}

private let cannedQuestions = [
    "Why did you choose this allocation?",
    "What's your investment timeline?",
    "Is any of this held in a tax-advantaged account, like an ISA or pension?"
]

struct PortfolioBreakdownView: View {
    @State private var step: PortfolioStep = .upload

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isProcessingUpload = false

    @State private var messages: [ChatMessage] = []
    @State private var draftMessage = ""
    @State private var isKogTyping = false
    @State private var questionIndex = 0
    @State private var conversationComplete = false

    var body: some View {
        VStack(spacing: 0) {
            progressHeader

            Group {
                switch step {
                case .upload:
                    uploadStep
                case .conversation:
                    conversationStep
                case .results:
                    resultsStep
                }
            }
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Portfolio Breakdown")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach([PortfolioStep.upload, .conversation, .results], id: \.self) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? Color.kognizePurple : Color.primary.opacity(0.15))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    // MARK: - Upload

    private var uploadStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.kognizePurple)
                    Text("Upload a portfolio screenshot")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("This is a preview of the flow — Kog isn't connected to a real image-analysis model yet, so nothing here reflects your actual holdings.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                if isProcessingUpload {
                    ProgressView("Analyzing...")
                        .tint(Color.kognizePurple)
                        .foregroundStyle(.primary)
                }

                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Text(selectedImageData == nil ? "Choose Photo" : "Choose a Different Photo")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        isProcessingUpload = true
                        selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
                        try? await Task.sleep(for: .milliseconds(900))
                        isProcessingUpload = false
                    }
                }

                if selectedImageData != nil && !isProcessingUpload {
                    Button {
                        withAnimation { step = .conversation }
                        seedConversation()
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.primary.opacity(0.08)))
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: - Conversation

    private var conversationStep: some View {
        VStack(spacing: 0) {
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

            if conversationComplete {
                Button {
                    withAnimation { step = .results }
                } label: {
                    Text("See Your Breakdown")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .padding()
            } else {
                inputBar
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Type your answer...", text: $draftMessage)
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

    private func seedConversation() {
        messages = []
        questionIndex = 0
        conversationComplete = false
        isKogTyping = true

        Task {
            try? await Task.sleep(for: .milliseconds(900))
            isKogTyping = false
            messages.append(ChatMessage(
                text: "Thanks — I can see a portfolio screenshot. This is a preview of the kind of conversation Kog will have with you once real analysis is connected.",
                isFromUser: false
            ))
            askNextQuestion()
        }
    }

    private func askNextQuestion() {
        guard questionIndex < cannedQuestions.count else {
            conversationComplete = true
            return
        }

        isKogTyping = true
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            isKogTyping = false
            messages.append(ChatMessage(text: cannedQuestions[questionIndex], isFromUser: false))
        }
    }

    private func send() {
        let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(text: text, isFromUser: true))
        draftMessage = ""
        questionIndex += 1

        if questionIndex < cannedQuestions.count {
            askNextQuestion()
        } else {
            isKogTyping = true
            Task {
                try? await Task.sleep(for: .milliseconds(900))
                isKogTyping = false
                messages.append(ChatMessage(
                    text: "Thanks — that's useful context. Here's a preview of what an observation might look like.",
                    isFromUser: false
                ))
                conversationComplete = true
            }
        }
    }

    // MARK: - Results

    private var resultsStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This is a preview using example data — Kog isn't yet connected to a real image-analysis model.")
                    .font(.footnote)
                    .foregroundStyle(.primary)

                resultCard(
                    icon: "chart.pie.fill",
                    heading: "Diversification & Concentration",
                    body: "Your holdings appear spread across 4 sectors, with the largest concentration in Technology at roughly 38% of the value shown. No single position looks to dominate the portfolio."
                )

                resultCard(
                    icon: "banknote.fill",
                    heading: "Estimated Dividend Income",
                    body: "Around £142 per year, estimated from the holdings identified in this upload. This figure is illustrative only."
                )

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.kognizePurple)
                        Text("Things to consider")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }

                    bulletRow("A large share of this portfolio sits in a single sector, which can make performance more sensitive to news in that sector.")
                    bulletRow("Roughly a third of the value shown isn't currently generating dividend income, based on what's visible in the upload.")
                    bulletRow("Some holdings appear across more than one account type, which is worth being aware of when reviewing total exposure.")
                }
                .padding(20)
                .background(widgetCardBackground())

                Button {
                    withAnimation {
                        step = .upload
                        selectedItem = nil
                        selectedImageData = nil
                    }
                } label: {
                    Text("Upload Another Photo")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.primary.opacity(0.08)))
                }
            }
            .padding(20)
        }
    }

    private func resultCard(icon: String, heading: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Color.kognizePurple)
                Text(heading)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Text(body)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(widgetCardBackground())
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.kognizePurple)
                .frame(width: 5, height: 5)
                .padding(.top, 7)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        PortfolioBreakdownView()
    }
}
