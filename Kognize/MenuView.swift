//
//  MenuView.swift
//  Kognize
//
//  Content of the floating hamburger menu — presented as a sheet from
//  MainTabView.
//

import SwiftUI

struct MenuView: View {
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ProfileView(onSignOut: onSignOut)
                } label: {
                    Label("Profile", systemImage: "person.crop.circle")
                }

                NavigationLink {
                    ComingSoonView(title: "Connected Accounts", systemImage: "link")
                } label: {
                    Label("Connected Accounts", systemImage: "link")
                }

                NavigationLink {
                    ComingSoonView(title: "App Security", systemImage: "lock.shield")
                } label: {
                    Label("App Security", systemImage: "lock.shield")
                }

                NavigationLink {
                    ComingSoonView(title: "Themes", systemImage: "paintbrush.fill")
                } label: {
                    Label("Themes", systemImage: "paintbrush.fill")
                }

                NavigationLink {
                    ComingSoonView(title: "Subscription", systemImage: "creditcard")
                } label: {
                    Label("Subscription", systemImage: "creditcard")
                }

                NavigationLink {
                    ComingSoonView(title: "Send Feedback", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                } label: {
                    Label("Send Feedback", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(Color.kognizePurple)
        }
    }
}

#Preview {
    MenuView(onSignOut: {})
}
