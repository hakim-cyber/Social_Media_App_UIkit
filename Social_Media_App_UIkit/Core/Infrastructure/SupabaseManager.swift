//
//  SupabaseManager.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/25/25.
//

import Foundation
import Supabase

 // ✅ GOOD - Single source of truth
 final class SupabaseManager {
     static let shared = SupabaseManager()
     let client: SupabaseClient
     
     private init() {
         client = SupabaseClient(supabaseURL: SupabaseConfig.supabaseURL, supabaseKey: SupabaseConfig.supabaseAnonKey)
     }
 }

////  Usage everywhere
// class FeedRepository {
//     private let supabase = SupabaseManager.shared.client  // Same instance
// }
// 

enum SupabaseConfig {
    static let supabaseURL = URL(string: "https://cursfbrdjilploelqmtp.supabase.co")!
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1cnNmYnJkamlscGxvZWxxbXRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3NDUzNzIsImV4cCI6MjA3NDMyMTM3Mn0.ikTvdSwXfCXpHUc5ViZT0y_etF6Lmhjb-xk-qeBJ-Zg"
}
