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
            Section {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            } header: {
                Text("Details").foregroundStyle(.primary)
            }

            Section {
                ZStack(alignment: .topLeading) {
                    if UserProfileStore.shared.bio.isEmpty {
                        Text("Tell Kog a bit about yourself — your goals, job, school status, or anything else relevant. This helps tailor the questions Kog asks you elsewhere in the app.")
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.35))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: Binding(
                        get: { UserProfileStore.shared.bio },
                        set: { UserProfileStore.shared.bio = $0 }
                    ))
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.primary)
                }
            } header: {
                Text("About You").foregroundStyle(.primary)
            }

            Section {
                NavigationLink {
                    ComingSoonView(title: "Change Passcode", systemImage: "lock.rotation")
                } label: {
                    Text("Change Passcode")
                }
            } header: {
                Text("Security").foregroundStyle(.primary)
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
