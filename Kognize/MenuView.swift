//
//  MenuView.swift
//  Kognize
//
//  Content of the floating hamburger menu — presented as a sheet from
//  MainTabView. Log Out is real (drops back to the disclaimer/lock flow),
//  same action as Profile's Sign Out — two access points to one action,
//  not a conflict.
//

import SwiftUI

struct MenuView: View {
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                        NotificationsView()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink {
                        ThemeSettingsView()
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

                logOutButton
            }
            .background(Color.kognizeBackground.ignoresSafeArea())
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(Color.kognizePurple)
        }
    }

    private var logOutButton: some View {
        Button(action: onSignOut) {
            Text("Log Out")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.red.opacity(0.85)))
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }
}

#Preview {
    MenuView(onSignOut: {})
}
