//
//  NotificationsView.swift
//  Kognize
//
//  Moved out of Profile into its own menu section. Toggles are local
//  state only — no push infrastructure yet (Build order step 8).
//

import SwiftUI

struct NotificationsView: View {
    @State private var isDailyDigestOn = true
    @State private var isScoreAlertsOn = true
    @State private var isGoalRemindersOn = true
    @State private var isSpendingAlertsOn = false

    var body: some View {
        List {
            Section("Daily") {
                Toggle("Daily Digest (8pm)", isOn: $isDailyDigestOn)
            }

            Section("Alerts") {
                Toggle("Score Changes", isOn: $isScoreAlertsOn)
                Toggle("Goal Reminders", isOn: $isGoalRemindersOn)
                Toggle("Unusual Spending", isOn: $isSpendingAlertsOn)
            }

            Section {
                Text("Notifications never show amounts, balances, or account names — generic text only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(Color.kognizePurple)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
