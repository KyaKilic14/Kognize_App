//
//  MainTabView.swift
//  Kognize
//
//  The post-unlock shell: bottom tab bar (Dashboard, Ask Kog, Goals) with a
//  floating hamburger button, fixed in the top-right regardless of tab or
//  scroll position, opening the menu sheet.
//

import SwiftUI

struct MainTabView: View {
    let onSignOut: () -> Void

    @State private var isMenuPresented = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "gauge.medium") }

                AskKogView()
                    .tabItem { Label("Ask Kog", systemImage: "message.fill") }

                GoalsView()
                    .tabItem { Label("Goals", systemImage: "target") }
            }
            .tint(Color.kognizePurple)

            hamburgerButton
                .padding(.top, 8)
                .padding(.trailing, 20)
        }
        .sheet(isPresented: $isMenuPresented) {
            MenuView {
                isMenuPresented = false
                onSignOut()
            }
        }
    }

    private var hamburgerButton: some View {
        Button {
            isMenuPresented = true
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.kognizePurple.opacity(0.25)))
                .overlay(Circle().strokeBorder(Color.kognizePurple.opacity(0.5), lineWidth: 1))
        }
    }
}

#Preview {
    MainTabView(onSignOut: {})
}
