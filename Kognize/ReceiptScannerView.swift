//
//  ReceiptScannerView.swift
//  Kognize
//
//  UI shell only — no real receipt-scanning/OCR model exists yet. Matches
//  Portfolio Breakdown's philosophy: real UI/flow, static canned
//  "extraction" that the user reviews and edits, wired for a real backend
//  later. Saves to History (not markdown — see CLAUDE.md's "Kog memory
//  tiering" note) and nudges FinanceStore's spending/score, so this is the
//  first feature whose result is actually visible on Dashboard.
//

import SwiftUI
import PhotosUI

private enum ReceiptStep: Int {
    case capture
    case breakdown
    case questions
    case confirmation
}

enum ReceiptCategory: String, CaseIterable, Identifiable {
    case groceries = "Groceries"
    case dining = "Dining"
    case shopping = "Shopping"
    case transport = "Transport"
    case other = "Other"

    var id: String { rawValue }
}

struct ReceiptScannerView: View {
    @State private var step: ReceiptStep = .capture

    // Capture
    @State private var selectedItem: PhotosPickerItem?
    @State private var receiptImageData: Data?
    @State private var isProcessingCapture = false
    @State private var isCameraPresented = false

    // Breakdown -- pre-filled with canned "extracted" values, fully editable
    @State private var merchantName = "Apple Store"
    @State private var receiptDate = Date()
    @State private var totalAmountText = "129.00"
    @State private var category: ReceiptCategory = .shopping

    // Questions
    @State private var currentQuestions: [String] = []
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
                case .capture:
                    captureStep
                case .breakdown:
                    breakdownStep
                case .questions:
                    questionsStep
                case .confirmation:
                    confirmationStep
                }
            }
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Receipt Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach([ReceiptStep.capture, .breakdown, .questions, .confirmation], id: \.self) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? Color.kognizePurple : Color.primary.opacity(0.15))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    // MARK: - Capture

    private var captureStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.kognizePurple)
                    Text("Scan a receipt")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("This is a preview of the flow — Kog isn't connected to a real receipt-scanning model yet, so nothing here reflects your actual purchase.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                if let receiptImageData, let uiImage = UIImage(data: receiptImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                if isProcessingCapture {
                    ProgressView("Reading receipt...")
                        .tint(Color.kognizePurple)
                        .foregroundStyle(.primary)
                }

                VStack(spacing: 12) {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            isCameraPresented = true
                        } label: {
                            Text(receiptImageData == nil ? "Take Photo" : "Retake Photo")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                        }
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        Text(receiptImageData == nil ? "Upload Photo" : "Choose a Different Photo")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.primary.opacity(0.08)))
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            isProcessingCapture = true
                            receiptImageData = try? await newItem?.loadTransferable(type: Data.self)
                            try? await Task.sleep(for: .milliseconds(900))
                            isProcessingCapture = false
                        }
                    }
                }

                if receiptImageData != nil && !isProcessingCapture {
                    Button {
                        withAnimation { step = .breakdown }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                    }
                }
            }
            .padding(24)
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraCaptureView { image in
                if let image, let data = image.jpegData(compressionQuality: 0.8) {
                    receiptImageData = data
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Breakdown (editable)

    private var breakdownStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Check the details")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("This is what Kog picked up from the receipt — edit anything that's not quite right before continuing.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }

                labeledField(title: "Merchant", text: $merchantName)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    DatePicker("", selection: $receiptDate, displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color.kognizePurple)
                }

                labeledField(title: "Total Amount (£)", text: $totalAmountText, keyboard: .decimalPad)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    Picker("Category", selection: $category) {
                        ForEach(ReceiptCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Button {
                    withAnimation { step = .questions }
                    seedConversation()
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .disabled(merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(totalAmountText) == nil)
            }
            .padding(24)
        }
    }

    private func labeledField(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
            TextField(title, text: text)
                .keyboardType(keyboard)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Questions

    private var questionsStep: some View {
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
                    finalizeAndSave()
                } label: {
                    Text("Save Receipt")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .padding()
            } else {
                VStack(spacing: 10) {
                    inputBar
                    Button("Skip for now") {
                        isKogTyping = false
                        conversationComplete = true
                    }
                    .font(.footnote)
                    .foregroundStyle(.primary)
                }
                .padding(.bottom, 8)
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
        .padding(.horizontal)
    }

    private var canSend: Bool {
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isKogTyping
    }

    private func seedConversation() {
        currentQuestions = questionsForCurrentReceipt()
        messages = []
        questionIndex = 0
        conversationComplete = false
        askNextQuestion()
    }

    /// Static/canned, but reads the (possibly user-edited) merchant name --
    /// a small demonstration of what real context-aware questions would
    /// look like once Kog is actually connected.
    private func questionsForCurrentReceipt() -> [String] {
        var questions: [String] = []
        if merchantName.localizedCaseInsensitiveContains("apple") {
            questions.append("Do you want to class this as a business write-off or a personal expense?")
        }
        questions.append("What was this purchase for?")
        return questions
    }

    private func askNextQuestion() {
        guard questionIndex < currentQuestions.count else {
            conversationComplete = true
            return
        }

        isKogTyping = true
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            isKogTyping = false
            messages.append(ChatMessage(text: currentQuestions[questionIndex], isFromUser: false))
        }
    }

    private func send() {
        let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(text: text, isFromUser: true))
        draftMessage = ""
        questionIndex += 1
        askNextQuestion()
    }

    // MARK: - Save + Confirmation

    private func finalizeAndSave() {
        let amount = Double(totalAmountText) ?? 0
        FinanceStore.shared.recordReceipt(amount: amount)

        let entry = HistoryEntry(
            date: Date(),
            title: "\(merchantName) — \(formattedGBP(amount))",
            content: .receiptScanner(
                merchant: merchantName,
                date: receiptDate,
                amount: amount,
                category: category.rawValue,
                messages: messages
            )
        )
        HistoryStore.shared.save(entry)

        withAnimation { step = .confirmation }
    }

    private var confirmationStep: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(Color.kognizePurple)

            Text("Receipt Saved")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("\(merchantName) · \(formattedGBP(Double(totalAmountText) ?? 0)) has been added to your spending and saved to History.")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                resetFlow()
            } label: {
                Text("Scan Another Receipt")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func resetFlow() {
        step = .capture
        selectedItem = nil
        receiptImageData = nil
        merchantName = "Apple Store"
        receiptDate = Date()
        totalAmountText = "129.00"
        category = .shopping
        messages = []
        questionIndex = 0
        conversationComplete = false
    }
}

#Preview {
    NavigationStack {
        ReceiptScannerView()
    }
}
