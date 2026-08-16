//
//  AnalyticsService.swift
//  Kognize
//
//  Lightweight, interim analytics/feedback pipeline -- posts to a Supabase
//  project (free tier) rather than the real backend, which doesn't exist
//  yet (Build order step 2). Deliberately narrow: only event names,
//  category labels, and an anonymous per-install device ID ever leave the
//  device. NEVER send amounts, balances, goal figures, or anything from
//  FinanceStore/NetWorthStore/SubscriptionStore/etc. -- this boundary is
//  the whole reason this file is separate from everything else in the app.
//
//  SETUP REQUIRED: create a free Supabase project, run the `events`/
//  `feedback` table SQL and anonymous-INSERT-only RLS policies from the
//  plan this was built from, then replace the two placeholder constants
//  below with the real project URL and anon public key. Until then, calls
//  here fail silently (see `send(to:body:)`) -- safe to ship without
//  blocking on account creation, but nothing is actually recorded yet.
//

import Foundation

private enum SupabaseConfig {
    static let projectURL = "https://YOUR-PROJECT.supabase.co"
    static let anonKey = "YOUR-ANON-PUBLIC-KEY"
}

@Observable
final class AnalyticsService {
    static let shared = AnalyticsService()

    private let deviceID: UUID

    private init() {
        let key = "kognize.analyticsDeviceID"
        if let stored = UserDefaults.standard.string(forKey: key), let id = UUID(uuidString: stored) {
            deviceID = id
        } else {
            let id = UUID()
            UserDefaults.standard.set(id.uuidString, forKey: key)
            deviceID = id
        }
    }

    func track(_ eventName: String, metadata: [String: String] = [:]) {
        let body: [String: Any] = [
            "device_id": deviceID.uuidString,
            "event_name": eventName,
            "metadata": metadata
        ]
        send(to: "events", body: body)
    }

    func submitFeedback(category: String, message: String) {
        let body: [String: Any] = [
            "device_id": deviceID.uuidString,
            "category": category,
            "message": message
        ]
        send(to: "feedback", body: body)
    }

    private func send(to table: String, body: [String: Any]) {
        guard !SupabaseConfig.projectURL.contains("YOUR-PROJECT"),
              let url = URL(string: "\(SupabaseConfig.projectURL)/rest/v1/\(table)"),
              let payload = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload

        URLSession.shared.dataTask(with: request).resume()
    }
}
