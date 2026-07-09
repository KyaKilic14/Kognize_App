//
//  DashboardView.swift
//  Kognize
//
//  Placeholder only — proves the navigation flow end-to-end.
//  Real score data arrives in a later build step.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gauge.medium")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))

            Text("Dashboard")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Your daily financial health score will live here.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea())
    }
}

#Preview {
    DashboardView()
}
