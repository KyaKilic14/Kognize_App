//
//  ThemeSettingsView.swift
//  Kognize
//
//  Fully functional: both pickers write straight to ThemeManager.shared,
//  which every screen already reads from (Color.kognizePurple) or is
//  driven by (AppRootView's .preferredColorScheme).
//

import SwiftUI

struct ThemeSettingsView: View {
    @State private var theme = ThemeManager.shared

    var body: some View {
        List {
            Section {
                ForEach(ThemeManager.accentOptions) { option in
                    Button {
                        theme.accentName = option.name
                    } label: {
                        HStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 22, height: 22)
                            Text(option.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if theme.accentName == option.name {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.kognizePurple)
                            }
                        }
                    }
                }
            } header: {
                Text("Accent Color").foregroundStyle(.primary)
            }

            Section {
                Picker("Appearance", selection: $theme.appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
            } header: {
                Text("Appearance").foregroundStyle(.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Themes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(Color.kognizePurple)
    }
}

#Preview {
    NavigationStack {
        ThemeSettingsView()
    }
}
