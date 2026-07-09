//
//  AccountsDetailView.swift
//  Kognize
//
//  Drill-down from the Dashboard's Accounts card. Placeholder rows until
//  the aggregator (TrueLayer/Yapily) and Trading212 integrations exist.
//

import SwiftUI

struct AccountsDetailView: View {
    var body: some View {
        List {
            Section("Bank") {
                Label("Not connected", systemImage: "building.columns")
                    .foregroundStyle(.secondary)
            }

            Section("Investments") {
                Label("Trading212 not connected", systemImage: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.secondary)
            }

            Section("Manual entries") {
                Label("No manual entries yet", systemImage: "pencil")
                    .foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Accounts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(Color.kognizePurple)
    }
}

#Preview {
    NavigationStack {
        AccountsDetailView()
    }
}
