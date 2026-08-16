//
//  CreditScoreDetailView.swift
//  Kognize
//
//  Bespoke detail view (like AccountsDetailView/NetWorthDetailView), not
//  the shared WidgetDetailView template -- needs history + projection
//  sections that template doesn't support. Design/UI shell only, no real
//  TransUnion integration -- see CreditScoreStore.swift.
//

import SwiftUI

struct CreditScoreDetailView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headline
                notConnectedNotice
                historySection
                projectionSection
            }
            .padding(.bottom, 20)
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Credit Score")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Headline

    private var headline: some View {
        VStack(spacing: 12) {
            Text("TransUnion Credit Score")
                .font(.subheadline)
                .foregroundStyle(.primary)

            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: min(Double(CreditScoreStore.shared.currentScore) / 710, 1))
                    .stroke(Color.kognizePurple, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(CreditScoreStore.shared.currentScore)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(CreditScoreStore.shared.band)
                        .font(.subheadline)
                        .foregroundStyle(Color.kognizePurple)
                }
            }
            .frame(width: 140, height: 140)

            Text("Out of 710 · Separate from your Kognize Score")
                .font(.footnote)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    // MARK: - Not connected notice

    private var notConnectedNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "link.badge.plus")
                .foregroundStyle(Color.kognizePurple)

            VStack(alignment: .leading, spacing: 4) {
                Text("TransUnion — Not Connected")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text("This is a preview of the design — Kog isn't connected to a real TransUnion feed yet, so nothing here reflects your actual credit file.")
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }
        }
        .padding(18)
        .background(widgetCardBackground())
        .padding(.horizontal, 20)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("History")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)

            VStack(spacing: 10) {
                ForEach(CreditScoreStore.shared.history) { snapshot in
                    HStack {
                        Text(snapshot.date.formatted(.dateTime.month(.wide).year()))
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(snapshot.score)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.05)))
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Projection

    private var projectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles").foregroundStyle(Color.kognizePurple)
                Text("Kog's take").font(.headline).foregroundStyle(.primary)
            }

            if let range = CreditScoreStore.shared.projectedRange {
                Text("Your score has trended upward over the last 6 months. If that trend continues, it could be roughly \(range.low)–\(range.high) in 3 months.")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text("An illustrative estimate based on recent trend — not a guarantee, and not financial advice.")
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.6))
            } else {
                Text("Not enough history yet to estimate a trend.")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
        .padding(20)
        .background(widgetCardBackground())
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        CreditScoreDetailView()
    }
}
