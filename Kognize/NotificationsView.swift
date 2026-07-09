//
//  NotificationsView.swift
//  Kognize
//
//  Moved out of Profile into its own menu section. Toggles are local
//  state only — no push infrastructure yet (Build order step 8).
//

import SwiftUI

private func defaultDigestTime() -> Date {
    Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
}

struct NotificationsView: View {
    @State private var isDailyDigestOn = true
    @State private var digestTime = defaultDigestTime()
    @State private var isScoreAlertsOn = true
    @State private var isGoalRemindersOn = true
    @State private var isSpendingAlertsOn = false

    var body: some View {
        List {
            Section {
                Toggle("Daily Digest", isOn: $isDailyDigestOn)

                if isDailyDigestOn {
                    DatePicker("Digest Time", selection: $digestTime, displayedComponents: .hourAndMinute)
                }
            } header: {
                Text("Daily").foregroundStyle(.primary)
            }

            Section {
                Toggle("Score Changes", isOn: $isScoreAlertsOn)
                Toggle("Goal Reminders", isOn: $isGoalRemindersOn)
                Toggle("Unusual Spending", isOn: $isSpendingAlertsOn)
            } header: {
                Text("Alerts").foregroundStyle(.primary)
            }

            Section {
                Text("Notifications never show amounts, balances, or account names — generic text only.")
                    .font(.caption)
                    .foregroundStyle(.primary)
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
