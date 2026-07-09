//
//  ComingSoonView.swift
//  Kognize
//
//  Generic placeholder destination for menu items that don't have a real
//  screen yet — keeps every tap leading somewhere instead of a dead end.
//

import SwiftUI

struct ComingSoonView: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(Color.kognizePurple)

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Coming soon.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ComingSoonView(title: "Themes", systemImage: "paintbrush.fill")
    }
}
