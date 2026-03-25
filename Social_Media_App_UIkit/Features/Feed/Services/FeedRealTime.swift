//
//  FeedRealTime.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/23/25.
//

import Foundation
import Supabase

final class FeedRealtime {
    struct Handlers {
        var onInsert: (RawPost) -> Void
        var onUpdate: (RawPost) -> Void
        var onDelete: (UUID) -> Void
    }

    private let client = SupabaseManager.shared.client
    private var channel: RealtimeChannelV2?
    private var insertTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?

    init() {
      
    }

    func subscribe(handlers: Handlers) async throws {
        // Avoid double subscription
        
        // If we already have one, remove it fully and recreate cleanly
           if let existing = channel {
               await client.realtimeV2.removeChannel(existing)
               channel = nil
           }

        let ch = client.realtimeV2.channel("posts_changes") // choose your topic name
        self.channel = ch

        // Insert stream
        let insertStream = ch.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "posts"
        )

        // Update stream
        let updateStream = ch.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "posts"
        )

        // Delete stream
        let deleteStream = ch.postgresChange(
            DeleteAction.self,
            schema: "public",
            table: "posts"
        )

        try await  ch.subscribeWithError() // Important: must await subscribe before reading streams

        insertTask = Task {
                    for await action in insertStream {
                        do {
                            let raw: RawPost = try action.decodeRecord(decoder: .postgresISO8601)
                            handlers.onInsert(raw)
                        } catch {
                            print("Realtime insert decode error:", error)
                        }
                    }
                }

               
                updateTask = Task {
                    for await action in updateStream {
                        do {
                            let raw: RawPost = try action.decodeRecord(decoder: .postgresISO8601)
                            handlers.onUpdate(raw)
                        } catch {
                            print("Realtime update decode error:", error)
                        }
                    }
                }

                deleteTask = Task {
                    for await action in deleteStream {
                        // For delete, decode the **old record** (the row being removed)
                        if let old = try? action.decodeOldRecord(decoder: .postgresISO8601) as RawPost {
                            handlers.onDelete(old.id)
                        } else if
                            let oldIdString = action.oldRecord["id"]?.stringValue ,
                            let id = UUID(uuidString: oldIdString)
                        {
                            handlers.onDelete(id)
                        }
                    }
                }
    }

    func unsubscribe() async {
        insertTask?.cancel()
        updateTask?.cancel()
        deleteTask?.cancel()

        if let ch = channel {
            await client.realtimeV2.removeChannel(ch)   // ✅ important
            channel = nil
        }
    }
}



// 1) Decoding helpers (dates with fractional seconds from Postgres)
extension JSONDecoder {
    static var postgresISO8601: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { dec in
            let s = try dec.singleValueContainer().decode(String.self)
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let dt = f.date(from: s) else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: dec.codingPath, debugDescription: "Bad date: \(s)")
                )
            }
            return dt
        }
        return d
    }
}

