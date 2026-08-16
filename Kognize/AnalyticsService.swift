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
//  Points at Kya's live "Kognize" Supabase project (eu-central-1). Uses
//  the publishable key -- Supabase's current name for what used to be
//  called the anon key, still safe to embed in a client app as long as
//  RLS only allows anonymous INSERT, which is how the events/feedback
//  tables were set up.
//

import Foundation

private enum SupabaseConfig {
    static let projectURL = "https://jemnaiulimwvwknnqnzm.supabase.co"
    static let anonKey = "sb_publishable_IdYvFs6s3b1IgIfIkCm0mA_42INYF-M"
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
