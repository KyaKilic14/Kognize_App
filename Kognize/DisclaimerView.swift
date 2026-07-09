//
//  DisclaimerView.swift
//  Kognize
//

import SwiftUI

struct DisclaimerView: View {
    let onAcknowledge: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))

            Text("Kognize")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            VStack(spacing: 16) {
                Text("Educational only. Not financial advice.")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Kognize reads your connected accounts to show you a daily financial health score and plain-language insights. It never moves money, never recommends buying or selling, and never has write access to any account.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button(action: onAcknowledge) {
                Text("I Understand")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea())
    }
}

#Preview {
    DisclaimerView(onAcknowledge: {})
}
