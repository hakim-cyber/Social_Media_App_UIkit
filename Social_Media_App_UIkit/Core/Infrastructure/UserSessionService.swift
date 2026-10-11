import Foundation
import Combine
import Supabase

@MainActor
protocol SessionStoreProtocol: AnyObject {
    var currentUser: User? { get }
    var isLoggedIn: Bool { get }
    var isLoggedInPublisher: AnyPublisher<Bool, Never> { get }

    func setSession(user: User, accessToken: String, refreshToken: String)
    func clearSession()
}

@MainActor
final class UserSessionService: ObservableObject, SessionStoreProtocol {
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoggedIn: Bool = false

    private(set) var accessToken: String?
    private(set) var refreshToken: String?

    var isLoggedInPublisher: AnyPublisher<Bool, Never> {
        $isLoggedIn
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private let supabase: SupabaseClient

    init(client: SupabaseClient) {
        self.supabase = client
        syncFromSupabase()
    }

    private func syncFromSupabase() {
        guard let user = supabase.auth.currentUser else {
            clearSession()
            return
        }

        currentUser = user
        isLoggedIn = true
    }

    func setSession(user: User, accessToken: String, refreshToken: String) {
        self.currentUser = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isLoggedIn = true
    }

    func clearSession() {
        currentUser = nil
        accessToken = nil
        refreshToken = nil
        isLoggedIn = false
    }
}
