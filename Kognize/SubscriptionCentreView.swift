//
//  SubscriptionCentreView.swift
//  Kognize
//
//  UI shell only — no real subscription-recognition model exists yet.
//  Same philosophy as Receipt Scanner/Portfolio Breakdown: real UI/flow,
//  simulated "recognition" the user can review, wired for a real backend
//  later. Distinct from the hamburger menu's "Subscription" item, which is
//  the app's own future paid-tier billing placeholder — this feature
//  tracks the user's own recurring subscriptions. Saves to History and
//  nudges FinanceStore's spending/score, same pattern Receipt Scanner
//  established.
//

import SwiftUI

private enum SubscriptionCentreStep: Int {
    case overview
    case form
    case questions
    case confirmation
}

struct SubscriptionCentreView: View {
    @State private var step: SubscriptionCentreStep = .overview
    @State private var editMode: EditMode = .inactive

    // Form -- shared between adding a new subscription and editing an existing one
    @State private var isEditingExistingID: UUID?
    @State private var draftName = ""
    @State private var draftCostText = ""
    @State private var draftFrequency: SubscriptionFrequency = .monthly

    // Questions (add flow only)
    @State private var currentQuestions: [String] = []
    @State private var messages: [ChatMessage] = []
    @State private var draftMessage = ""
    @State private var isKogTyping = false
    @State private var questionIndex = 0
    @State private var conversationComplete = false

    var body: some View {
        Group {
            switch step {
            case .overview:
                overviewStep
            case .form:
                formStep
            case .questions:
                questionsStep
            case .confirmation:
                confirmationStep
            }
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Subscription Centre")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if step == .overview {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation { editMode = editMode == .active ? .inactive : .active }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                    }
                }
            }
        }
    }

    // MARK: - Overview

    private var overviewStep: some View {
        List {
            Section {
                summaryCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                if SubscriptionStore.shared.subscriptions.isEmpty {
                    emptyRow
                } else {
                    ForEach(SubscriptionStore.shared.subscriptions) { subscription in
                        subscriptionRow(subscription)
                            .onTapGesture {
                                if editMode == .active {
                                    beginEditing(subscription)
                                }
                            }
                    }
                    .onDelete { indices in
                        SubscriptionStore.shared.subscriptions.remove(atOffsets: indices)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $editMode)
        .safeAreaInset(edge: .bottom) {
            if editMode != .active {
                addButton
            }
        }
    }

    private var summaryCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.kognizePurple)

            VStack(alignment: .leading, spacing: 4) {
                Text("Kog says")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(summaryText)
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(18)
        .background(widgetCardBackground())
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var summaryText: String {
        let count = SubscriptionStore.shared.subscriptions.count
        guard count > 0 else {
            return "You don't have any subscriptions tracked yet — tap + to add one."
        }
        return "You have \(count) active subscription\(count == 1 ? "" : "s") costing an estimated \(formattedGBP(SubscriptionStore.shared.estimatedMonthlyCost)) per month."
    }

    private var emptyRow: some View {
        Text("No subscriptions tracked yet.")
            .font(.subheadline)
            .foregroundStyle(.primary)
            .padding(18)
    }

    private func subscriptionRow(_ subscription: Subscription) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.kognizePurple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(formattedGBP(subscription.cost)) · \(subscription.frequency.rawValue)")
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(18)
        .background(widgetCardBackground())
    }

    private var addButton: some View {
        HStack {
            Spacer()
            Button {
                beginAdding()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Color.kognizePurple))
            }
            Spacer()
        }
        .padding(.bottom, 12)
    }

    private func beginAdding() {
        isEditingExistingID = nil
        draftName = ""
        draftCostText = ""
        draftFrequency = .monthly
        withAnimation { step = .form }
    }

    private func beginEditing(_ subscription: Subscription) {
        isEditingExistingID = subscription.id
        draftName = subscription.name
        draftCostText = String(subscription.cost)
        draftFrequency = subscription.frequency
        withAnimation { step = .form }
    }

    // MARK: - Form (add or edit)

    private var formStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(isEditingExistingID == nil ? "Add a subscription" : "Edit subscription")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("Name, cost, and how often it bills.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }

                labeledField(title: "Name", text: $draftName)
                labeledField(title: "Cost (£)", text: $draftCostText, keyboard: .decimalPad)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Billing Frequency")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    Picker("Billing Frequency", selection: $draftFrequency) {
                        ForEach(SubscriptionFrequency.allCases) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Button {
                    confirmForm()
                } label: {
                    Text(isEditingExistingID == nil ? "Next" : "Save")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(draftCostText) == nil)
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

    /// Editing an existing subscription skips the Q&A entirely (a "why did
    /// you choose this" question only makes sense for a brand-new one) and
    /// doesn't re-touch FinanceStore, which would double-count the cost.
    private func confirmForm() {
        if let existingID = isEditingExistingID {
            guard let index = SubscriptionStore.shared.subscriptions.firstIndex(where: { $0.id == existingID }) else {
                withAnimation { step = .overview }
                return
            }
            SubscriptionStore.shared.subscriptions[index].name = draftName
            SubscriptionStore.shared.subscriptions[index].cost = Double(draftCostText) ?? 0
            SubscriptionStore.shared.subscriptions[index].frequency = draftFrequency
            withAnimation { step = .overview }
        } else {
            withAnimation { step = .questions }
            seedConversation()
        }
    }

    // MARK: - Questions (add flow only)

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
                    Text("Save Subscription")
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
        currentQuestions = questionsForCurrentSubscription()
        messages = []
        questionIndex = 0
        conversationComplete = false
        askNextQuestion()
    }

    /// Simulated recognition only — no real internet lookup. A small
    /// known-service table, same spirit as Receipt Scanner's single
    /// Apple-merchant conditional, extended to a short list.
    private func questionsForCurrentSubscription() -> [String] {
        let knownServices: [(keywords: [String], description: String)] = [
            (["netflix"], "a video streaming subscription"),
            (["spotify"], "a music streaming subscription"),
            (["apple"], "an Apple service"),
            (["amazon", "prime"], "Amazon Prime"),
            (["gym", "fitness", "peloton"], "a fitness/gym membership")
        ]

        var questions: [String] = []
        if let matched = knownServices.first(where: { entry in
            entry.keywords.contains { draftName.localizedCaseInsensitiveContains($0) }
        }) {
            questions.append("Kog recognizes \(draftName) as \(matched.description). Why did you choose it?")
        } else {
            questions.append("What's \(draftName) for?")
        }

        questions.append("What's the predicted timeframe you'll keep this subscription? (e.g. a few months, long-term, not sure)")
        questions.append(benefitQuestion())
        return questions
    }

    /// Reads UserProfileStore's bio so the question reflects what the user
    /// has already told Kog, rather than asking for the same info twice.
    private func benefitQuestion() -> String {
        let bio = UserProfileStore.shared.bio.lowercased()
        if bio.contains("business") || bio.contains("work") || bio.contains("job") || bio.contains("freelance") {
            return "Does \(draftName) mainly benefit your work or business, or is it more personal?"
        } else if bio.contains("school") || bio.contains("student") || bio.contains("university") || bio.contains("college") {
            return "Is \(draftName) something that supports your studies, or more of a personal/family thing?"
        } else {
            return "Is \(draftName) mainly a personal expense, or something the whole family uses?"
        }
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
        let cost = Double(draftCostText) ?? 0
        let frequency = draftFrequency

        SubscriptionStore.shared.subscriptions.append(
            Subscription(name: draftName, cost: cost, frequency: frequency)
        )
        FinanceStore.shared.recordSubscription(cost: cost, frequency: frequency)

        let entry = HistoryEntry(
            date: Date(),
            title: "\(draftName) — \(formattedGBP(cost))/\(frequency.rawValue)",
            content: .subscriptionCentre(
                name: draftName,
                cost: cost,
                frequency: frequency.rawValue,
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

            Text("Subscription Saved")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("\(draftName) · \(formattedGBP(Double(draftCostText) ?? 0))/\(draftFrequency.rawValue) has been added to your spending and saved to History.")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                resetFlow()
            } label: {
                Text("Back to Subscriptions")
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
        step = .overview
        isEditingExistingID = nil
        draftName = ""
        draftCostText = ""
        draftFrequency = .monthly
        messages = []
        questionIndex = 0
        conversationComplete = false
    }
}

#Preview {
    NavigationStack {
        SubscriptionCentreView()
    }
}
