//
//  DashboardView.swift
//  Kognize
//
//  Static placeholder data — real score data arrives once the Kog scoring
//  endpoint exists (Build order step 5). Widget order/visibility resets on
//  relaunch — no persistence yet, matching every other screen this session.
//

import SwiftUI

private enum DashboardWidgetKind: String, CaseIterable, Identifiable {
    case score
    case kogSummary
    case spending
    case income
    case scoreHistory
    case investments
    case accounts

    var id: String { rawValue }
}

struct DashboardView: View {
    @State private var widgetOrder = DashboardWidgetKind.allCases
    @State private var editMode: EditMode = .inactive

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    header
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section {
                    ForEach(widgetOrder) { kind in
                        widgetView(for: kind)
                    }
                    .onMove { indices, newOffset in
                        widgetOrder.move(fromOffsets: indices, toOffset: newOffset)
                    }
                    .onDelete { indices in
                        widgetOrder.remove(atOffsets: indices)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    editButton
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.kognizeBackground.ignoresSafeArea())
            .environment(\.editMode, $editMode)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date(), style: .date)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("\(greeting), Kya")
                .font(.title2.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var editButton: some View {
        Button {
            withAnimation {
                editMode = editMode == .active ? .inactive : .active
            }
        } label: {
            Text(editMode == .active ? "Done" : "Edit Dashboard")
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.kognizePurple.opacity(editMode == .active ? 1 : 0.25))
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private func widgetView(for kind: DashboardWidgetKind) -> some View {
        switch kind {
        case .score:
            ScoreCardWidget()
        case .kogSummary:
            KogSummaryWidget()
        case .spending:
            SpendingTrackerWidget()
        case .income:
            IncomeTrackerWidget()
        case .scoreHistory:
            ScoreHistoryWidget()
        case .investments:
            InvestmentTrackerWidget()
        case .accounts:
            AccountsSummaryWidget()
        }
    }
}

#Preview {
    DashboardView()
}
