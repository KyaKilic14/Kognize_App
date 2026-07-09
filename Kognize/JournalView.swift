//
//  JournalView.swift
//  Kognize
//
//  Bottom-tab destination combining free-text Journal entries and the
//  Spending Context MCQ (moved here from the hamburger menu per Kya's
//  call — important enough to live in the tab bar, and naturally part of
//  the same "context you give Kog" concept). Entries live in memory only
//  for now — no persistence layer yet.
//

import SwiftUI

private enum JournalSection: String, CaseIterable {
    case entries = "Entries"
    case spendingContext = "Spending Context"
}

private struct JournalEntry: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
}

struct JournalView: View {
    @State private var section: JournalSection = .entries
    @State private var entries: [JournalEntry] = []
    @State private var isComposePresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $section) {
                    ForEach(JournalSection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                switch section {
                case .entries:
                    entriesContent
                case .spendingContext:
                    SpendingStressView()
                }
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                // Leading, not trailing -- avoids sitting under the
                // always-on-top-right floating hamburger menu.
                if section == .entries {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isComposePresented = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.kognizePurple)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isComposePresented) {
            JournalComposeView { text in
                entries.insert(JournalEntry(date: Date(), text: text), at: 0)
            }
        }
    }

    @ViewBuilder
    private var entriesContent: some View {
        if entries.isEmpty {
            emptyState
        } else {
            entryList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "book.closed")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(Color.kognizePurple)

            Text("No entries yet")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Jot down anything about your finances — Kog can reference it later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var entryList: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(entry.text)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.05)))
                }
            }
            .padding(20)
        }
    }
}

private struct JournalComposeView: View {
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.primary.opacity(0.08))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(20)
                .background(Color.kognizeBackground.ignoresSafeArea())
                .navigationTitle("New Entry")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(.secondary)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            onSave(text)
                            dismiss()
                        }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .tint(Color.kognizePurple)
                    }
                }
        }
    }
}

#Preview {
    JournalView()
}
