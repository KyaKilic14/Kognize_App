//
//  MoreView.swift
//  Kognize
//
//  The tab-bar hub for lower-frequency features — deliberately separate
//  from MenuView (which is account/app settings). This is where new
//  product features get a home going forward instead of crowding the
//  bottom tab bar.
//

import SwiftUI

private enum MoreFeatureKind: String, CaseIterable, Identifiable {
    case journal
    case spendingContext
    case portfolioBreakdown
    case receiptScanner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .journal: return "Journal"
        case .spendingContext: return "Spending Context"
        case .portfolioBreakdown: return "Portfolio Breakdown"
        case .receiptScanner: return "Receipt Scanner"
        }
    }

    var subtitle: String {
        switch self {
        case .journal: return "Free-form notes Kog can reference later"
        case .spendingContext: return "What's been affecting your spending lately"
        case .portfolioBreakdown: return "Upload a portfolio screenshot for a preview breakdown"
        case .receiptScanner: return "Scan or upload a receipt to log a purchase"
        }
    }

    var icon: String {
        switch self {
        case .journal: return "book.closed"
        case .spendingContext: return "bolt.heart.fill"
        case .portfolioBreakdown: return "chart.pie.fill"
        case .receiptScanner: return "doc.text.viewfinder"
        }
    }
}

struct MoreView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(MoreFeatureKind.allCases) { kind in
                        NavigationLink {
                            destination(for: kind)
                        } label: {
                            card(for: kind)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func card(for kind: MoreFeatureKind) -> some View {
        HStack(spacing: 14) {
            Image(systemName: kind.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.kognizePurple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(kind.subtitle)
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

    @ViewBuilder
    private func destination(for kind: MoreFeatureKind) -> some View {
        switch kind {
        case .journal:
            JournalView()
        case .spendingContext:
            SpendingStressView()
        case .portfolioBreakdown:
            PortfolioBreakdownView()
        case .receiptScanner:
            ReceiptScannerView()
        }
    }
}

#Preview {
    MoreView()
}
