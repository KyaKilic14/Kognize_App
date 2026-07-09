//
//  SpendingStressView.swift
//  Kognize
//
//  This is the "Context input" feature from the master plan, made
//  concrete: what's stressing the user's spending becomes context Kog can
//  reference in chat later. Local-only for now, no backend context layer
//  yet (Build order step 10).
//

import SwiftUI

private enum SpendingStressor: String, CaseIterable, Identifiable {
    case carExpense = "Unexpected car expense"
    case propertyDamage = "Home or property damage"
    case medical = "Medical expense"
    case jobLoss = "Job loss or reduced income"
    case inflation = "Rising prices / inflation"
    case debt = "Debt repayment"
    case family = "Supporting family or dependents"
    case lifeEvent = "Major life event (wedding, moving, etc.)"

    var id: String { rawValue }
}

struct SpendingStressView: View {
    @State private var selected: Set<SpendingStressor> = []
    @State private var isOtherSelected = false
    @State private var otherText = ""
    @State private var didSave = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's been stressing your spending lately?")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("Select anything that applies. Kog uses this as context when you ask questions — it never changes your score directly.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }

                VStack(spacing: 10) {
                    ForEach(SpendingStressor.allCases) { stressor in
                        optionRow(title: stressor.rawValue, isSelected: selected.contains(stressor)) {
                            if selected.contains(stressor) {
                                selected.remove(stressor)
                            } else {
                                selected.insert(stressor)
                            }
                            didSave = false
                        }
                    }

                    optionRow(title: "Other", isSelected: isOtherSelected) {
                        isOtherSelected.toggle()
                        didSave = false
                    }
                }

                if isOtherSelected {
                    TextField("Tell Kog more...", text: $otherText, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.08)))
                        .foregroundStyle(.primary)
                }

                Button(action: save) {
                    Text(didSave ? "Saved" : "Save")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.kognizePurple))
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.kognizeBackground.ignoresSafeArea())
    }

    private func optionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.kognizePurple : Color.primary.opacity(0.3))
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(isSelected ? 0.1 : 0.05)))
        }
        .buttonStyle(.plain)
    }

    private func save() {
        didSave = true
    }
}

#Preview {
    NavigationStack {
        SpendingStressView()
    }
}
