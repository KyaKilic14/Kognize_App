//
//  WidgetDetailView.swift
//  Kognize
//
//  Generic drill-down shared by every Dashboard widget — one template
//  instead of a bespoke screen per metric. Timeframe picker and insight
//  text are static until real data/Kog exist.
//

import SwiftUI

struct WidgetDetailView: View {
    let title: String
    let systemImage: String
    let headlineValue: String
    let headlineLabel: String
    let kogInsight: String

    private let timeframes = ["1W", "1M", "3M", "6M", "1Y"]
    @State private var selectedTimeframe = "1M"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.kognizePurple)

                    Text(headlineValue)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)

                    Text(headlineLabel)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)

                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(timeframes, id: \.self) { frame in
                        Text(frame).tag(frame)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.kognizePurple)
                        Text("Kog's take")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }

                    Text(kogInsight)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 20)
            }
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(Color.kognizePurple)
    }
}

#Preview {
    NavigationStack {
        WidgetDetailView(
            title: "Spending",
            systemImage: "arrow.down.circle.fill",
            headlineValue: "£1,240",
            headlineLabel: "This month",
            kogInsight: "Spending is 12% above your typical month, mostly in dining and transport."
        )
    }
}
