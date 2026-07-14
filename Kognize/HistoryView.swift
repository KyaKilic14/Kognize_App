//
//  HistoryView.swift
//  Kognize
//
//  Read-only record of past feature results (Portfolio Breakdowns, saved
//  Ask Kog conversations) -- lives in the hamburger menu, not the More
//  hub, since it's a record of what's already happened rather than a
//  feature to go use. In-memory only for now, same as everything it
//  saves.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        Group {
            if HistoryStore.shared.entries.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(Color.kognizePurple)

            Text("Nothing saved yet")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Completed Portfolio Breakdowns and saved Ask Kog conversations will show up here.")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(HistoryStore.shared.entries) { entry in
                    NavigationLink {
                        HistoryDetailView(entry: entry)
                    } label: {
                        row(for: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }

    private func row(for entry: HistoryEntry) -> some View {
        HStack(spacing: 14) {
            Image(systemName: entry.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.kognizePurple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(entry.featureLabel) · \(entry.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(widgetCardBackground())
    }
}

struct HistoryDetailView: View {
    let entry: HistoryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Saved \(entry.date.formatted(date: .abbreviated, time: .shortened)) · Read-only")
                    .font(.footnote)
                    .foregroundStyle(.primary)

                switch entry.content {
                case .portfolioBreakdown(let diversification, let dividendEstimate, let considerations):
                    portfolioContent(diversification: diversification, dividendEstimate: dividendEstimate, considerations: considerations)
                case .askKogConversation(let messages):
                    conversationContent(messages: messages)
                }
            }
            .padding(20)
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func portfolioContent(diversification: String, dividendEstimate: String, considerations: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            resultCard(icon: "chart.pie.fill", heading: "Diversification & Concentration", body: diversification)
            resultCard(icon: "banknote.fill", heading: "Estimated Dividend Income", body: dividendEstimate)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles").foregroundStyle(Color.kognizePurple)
                    Text("Things to consider").font(.headline).foregroundStyle(.primary)
                }
                ForEach(considerations, id: \.self) { item in
                    bulletRow(item)
                }
            }
            .padding(20)
            .background(widgetCardBackground())

            educationalTopicsCard()
        }
    }

    private func conversationContent(messages: [ChatMessage]) -> some View {
        VStack(spacing: 12) {
            ForEach(messages) { message in
                ChatBubble(message: message)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
