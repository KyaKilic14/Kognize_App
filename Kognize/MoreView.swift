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
    case subscriptionCentre

    var id: String { rawValue }

    var title: String {
        switch self {
        case .journal: return "Journal"
        case .spendingContext: return "Spending Context"
        case .portfolioBreakdown: return "Portfolio Breakdown"
        case .receiptScanner: return "Receipt Scanner"
        case .subscriptionCentre: return "Subscription Centre"
        }
    }

    var subtitle: String {
        switch self {
        case .journal: return "Free-form notes Kog can reference later"
        case .spendingContext: return "What's been affecting your spending lately"
        case .portfolioBreakdown: return "Upload a portfolio screenshot for a preview breakdown"
        case .receiptScanner: return "Scan or upload a receipt to log a purchase"
        case .subscriptionCentre: return "Track your recurring subscriptions and their cost"
        }
    }

    var icon: String {
        switch self {
        case .journal: return "book.closed"
        case .spendingContext: return "bolt.heart.fill"
        case .portfolioBreakdown: return "chart.pie.fill"
        case .receiptScanner: return "doc.text.viewfinder"
        case .subscriptionCentre: return "arrow.triangle.2.circlepath"
        }
    }
}

struct MoreView: View {
    @State private var featureOrder: [MoreFeatureKind] = MoreFeatureKind.allCases
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            List {
                ForEach(featureOrder) { kind in
                    NavigationLink {
                        destination(for: kind)
                    } label: {
                        card(for: kind)
                    }
                    .buttonStyle(.plain)
                }
                .onMove { indices, newOffset in
                    featureOrder.move(fromOffsets: indices, toOffset: newOffset)
                }
                .listRowInsets(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
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
        case .subscriptionCentre:
            SubscriptionCentreView()
        }
    }
}

#Preview {
    MoreView()
}
