//
//  UserProfileStore.swift
//  Kognize
//
//  Shared, in-memory (no persistence yet) store for what the user has told
//  Kog about themselves -- goals, job, school status, anything relevant.
//  Read by other features (starting with Subscription Centre) to tailor
//  the questions Kog asks, the same way FinanceStore backs Dashboard's
//  widgets. Not written to CLAUDE.md or any markdown file -- see "Kog
//  memory tiering" in CLAUDE.md for why user data lives in a store like
//  this one, not project docs.
//

import Foundation

@Observable
final class UserProfileStore {
    static let shared = UserProfileStore()

    var bio: String = ""

    private init() {}
}
