//
//  ProfileView.swift
//  Kognize
//
//  Frontend-only: fields are editable in the UI but nothing persists yet.
//  Sign Out is fully real, though — it drops back to the disclaimer/lock
//  flow, which doesn't need any backend to be genuine behavior.
//

import SwiftUI

struct ProfileView: View {
    let onSignOut: () -> Void

    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        List {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section("Security") {
                NavigationLink {
                    ComingSoonView(title: "Change Passcode", systemImage: "lock.rotation")
                } label: {
                    Text("Change Passcode")
                }
            }

            Section {
                Button(role: .destructive, action: onSignOut) {
                    Text("Sign Out")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.kognizeBackground.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.kognizeBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(Color.kognizePurple)
    }
}

#Preview {
    NavigationStack {
        ProfileView(onSignOut: {})
    }
}
