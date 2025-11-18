//
//  AuthorCache.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/24/25.
//
import Foundation
import Foundation

// Simple value wrapper with an expiry deadline
private struct Cached<Value> {
    let value: Value
    let expiry: Date
}

/// Concurrency-safe cache for UserSummary
actor AuthorCache {
    private var store: [UUID: Cached<UserSummary>] = [:]
    private var inflight: [UUID: Task<UserSummary, Error>] = [:]

    // Config
    private let ttl: TimeInterval
    private let maxEntries: Int

    init(ttl: TimeInterval = 10 * 60, maxEntries: Int = 500) {
        self.ttl = ttl
        self.maxEntries = maxEntries
    }

    /// Get if present and not expired
    func get(_ id: UUID) -> UserSummary? {
        guard let cached = store[id] else { return nil }
        // ✅ Do the expiry check here (no computed property to trip isolation)
        if Date() >= cached.expiry {
            store[id] = nil
            return nil
        }
        return cached.value
    }

    /// Put / update
    func set(_ id: UUID, _ value: UserSummary) {
        store[id] = Cached(value: value, expiry: Date().addingTimeInterval(ttl))
        evictIfNeeded()
    }

    /// Get or fetch (dedupe concurrent fetches)
    func getOrFetch(_ id: UUID, fetcher: @escaping (UUID) async throws -> UserSummary) async throws -> UserSummary {
        if let hit = get(id) { return hit }

        if let task = inflight[id] {
            return try await task.value
        }

        let task = Task<UserSummary, Error> {
            defer { Task {  self.clearInflight(id) } }
            let value = try await fetcher(id)
             self.set(id, value)
            return value
        }
        inflight[id] = task
        return try await task.value
    }

    private func clearInflight(_ id: UUID) {
        inflight[id] = nil
    }

    /// Evict if above capacity (drop soonest-expiring first)
    private func evictIfNeeded() {
        guard store.count > maxEntries else { return }
        let sorted = store.sorted { $0.value.expiry < $1.value.expiry }
        for (idx, pair) in sorted.enumerated() where store.count > maxEntries {
            store.removeValue(forKey: pair.key)
            if idx >= 32 { break } // remove in small batches
        }
    }

    func invalidate(_ id: UUID) { store[id] = nil }
    func clear() {
        store.removeAll(keepingCapacity: false)
        inflight.removeAll(keepingCapacity: false)
    }
}
