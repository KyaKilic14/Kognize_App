//
//  AskKogView.swift
//  Kognize
//
//  Placeholder tab — the input is static until the Kog scoring/chat
//  endpoint exists (Build order steps 5 and 7).
//

import SwiftUI

struct AskKogView: View {
    @State private var draftMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.kognizePurple)

                    Text("Ask Kog")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Ask a question about your finances — always educational, never advice.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                HStack(spacing: 12) {
                    TextField("Ask Kog anything...", text: $draftMessage)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )

                    Button {
                        draftMessage = ""
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(draftMessage.isEmpty ? Color.white.opacity(0.2) : Color.kognizePurple)
                    }
                    .disabled(draftMessage.isEmpty)
                }
                .padding()
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Ask Kog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    AskKogView()
}
