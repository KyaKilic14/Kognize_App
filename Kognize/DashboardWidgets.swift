//
//  DashboardWidgets.swift
//  Kognize
//
//  Individual Dashboard card views. All values are static placeholders
//  until real (sandbox) data exists — Build order steps 3-5.
//

import SwiftUI

private func widgetCardBackground() -> some View {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color.primary.opacity(0.05))
}

private func metricRow(icon: String, title: String, value: String, subtitle: String) -> some View {
    HStack(spacing: 14) {
        Image(systemName: icon)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(Color.kognizePurple)
            .frame(width: 32)

        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.primary)
        }

        Spacer()

        Text(value)
            .font(.headline)
            .foregroundStyle(.primary)
    }
    .padding(16)
    .background(widgetCardBackground())
}

struct ScoreCardWidget: View {
    var body: some View {
        NavigationLink {
            WidgetDetailView(
                title: "Score",
                systemImage: "gauge.medium",
                headlineValue: "82",
                headlineLabel: "Healthy",
                kogInsight: "Your score has been steady this week. Spending is in line with your typical month, and no unusual activity was detected."
            )
        } label: {
            VStack(spacing: 12) {
                Text("Today's Score")
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: 0.82)
                        .stroke(Color.kognizePurple, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        Text("82")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("Healthy")
                            .font(.subheadline)
                            .foregroundStyle(Color.kognizePurple)
                    }
                }
                .frame(width: 140, height: 140)

                Text("Spending is on track with your typical month.")
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(widgetCardBackground())
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.kognizePurple.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct KogSummaryWidget: View {
    var body: some View {
        NavigationLink {
            WidgetDetailView(
                title: "Kog's Summary",
                systemImage: "sparkles",
                headlineValue: "3",
                headlineLabel: "Highlights",
                kogInsight: "Spending is up 12% versus your typical week, mostly dining out. Your score improved 4 points since last month. Your Emergency Fund goal is on track."
            )
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.kognizePurple)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Kog says")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("Spending is up 12% vs. your typical week, mostly dining out.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                    Text("Score improved 4 points since last month.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                    Text("Emergency Fund goal is on track.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }

                Spacer()
            }
            .padding(18)
            .background(widgetCardBackground())
        }
        .buttonStyle(.plain)
    }
}

struct SpendingTrackerWidget: View {
    var body: some View {
        NavigationLink {
            WidgetDetailView(
                title: "Spending",
                systemImage: "arrow.down.circle.fill",
                headlineValue: "£1,240",
                headlineLabel: "This month",
                kogInsight: "Spending is 12% above your typical month, mostly in dining and transport."
            )
        } label: {
            metricRow(icon: "arrow.down.circle.fill", title: "Spending", value: "£1,240", subtitle: "This month · +12% vs. usual")
        }
        .buttonStyle(.plain)
    }
}

struct IncomeTrackerWidget: View {
    var body: some View {
        NavigationLink {
            WidgetDetailView(
                title: "Income",
                systemImage: "arrow.up.circle.fill",
                headlineValue: "£2,850",
                headlineLabel: "This month",
                kogInsight: "Income is consistent with your typical month."
            )
        } label: {
            metricRow(icon: "arrow.up.circle.fill", title: "Income", value: "£2,850", subtitle: "This month · on par with usual")
        }
        .buttonStyle(.plain)
    }
}

struct InvestmentTrackerWidget: View {
    @State private var isAddSheetPresented = false

    var body: some View {
        HStack(spacing: 0) {
            NavigationLink {
                WidgetDetailView(
                    title: "Investments",
                    systemImage: "chart.line.uptrend.xyaxis",
                    headlineValue: "£4,120",
                    headlineLabel: "Portfolio value",
                    kogInsight: "Your portfolio is up slightly this month. This is observational only — Kog never recommends buying or selling."
                )
            } label: {
                metricRow(icon: "chart.line.uptrend.xyaxis", title: "Investments", value: "£4,120", subtitle: "Portfolio value")
            }
            .buttonStyle(.plain)

            Button {
                isAddSheetPresented = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.kognizePurple)
            }
            .padding(.leading, 12)
        }
        .sheet(isPresented: $isAddSheetPresented) {
            NavigationStack {
                ComingSoonView(title: "Add Investment", systemImage: "plus.circle")
            }
            .preferredColorScheme(ThemeManager.shared.appearanceMode.colorScheme)
        }
    }
}

struct ScoreHistoryWidget: View {
    private let deltas: [(label: String, value: Int)] = [
        ("1W", 3), ("1M", 8), ("3M", -2), ("6M", 15)
    ]

    var body: some View {
        NavigationLink {
            WidgetDetailView(
                title: "Score History",
                systemImage: "chart.xyaxis.line",
                headlineValue: "+8",
                headlineLabel: "Last 1 month",
                kogInsight: "Your score has trended upward over the last 6 months, with a small dip 3 months ago."
            )
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text("Score Change")
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 10) {
                    ForEach(deltas, id: \.label) { delta in
                        VStack(spacing: 4) {
                            Text(delta.label)
                                .font(.caption2)
                                .foregroundStyle(.primary)
                            Text(delta.value >= 0 ? "+\(delta.value)" : "\(delta.value)")
                                .font(.subheadline.bold())
                                .foregroundStyle(delta.value >= 0 ? Color.kognizePurple : Color.red.opacity(0.85))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.primary.opacity(0.05))
                        )
                    }
                }
            }
            .padding(18)
            .background(widgetCardBackground())
        }
        .buttonStyle(.plain)
    }
}

struct AccountsSummaryWidget: View {
    var body: some View {
        NavigationLink {
            AccountsDetailView()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Accounts")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Bank, investments, and manual entries")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(widgetCardBackground())
        }
        .buttonStyle(.plain)
    }
}
