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
            Section {
                Label("Not connected", systemImage: "building.columns")
                    .foregroundStyle(.primary)
            } header: {
                Text("Bank").foregroundStyle(.primary)
            }

            Section {
                Label("Trading212 not connected", systemImage: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.primary)
            } header: {
                Text("Investments").foregroundStyle(.primary)
            }

            Section {
                Label("No manual entries yet", systemImage: "pencil")
                    .foregroundStyle(.primary)
            } header: {
                Text("Manual entries").foregroundStyle(.primary)
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
