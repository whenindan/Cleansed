//
//  AuthManager.swift
//  Cleansed
//

import Foundation
import Supabase

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserId: UUID?
    @Published var currentUserEmail: String?

    init() {
        Task { await checkSession() }
    }

    // MARK: - Session

    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            self.isAuthenticated = true
            self.currentUserId = session.user.id
            self.currentUserEmail = session.user.email
        } catch {
            self.isAuthenticated = false
            self.currentUserId = nil
            self.currentUserEmail = nil
        }
    }

    // MARK: - Auth Actions

    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )
        if let session = response.session {
            self.isAuthenticated = true
            self.currentUserId = session.user.id
            self.currentUserEmail = session.user.email
        }
    }

    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        self.isAuthenticated = true
        self.currentUserId = session.user.id
        self.currentUserEmail = session.user.email
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        self.isAuthenticated = false
        self.currentUserId = nil
        self.currentUserEmail = nil
    }

    // MARK: - Deep Link (for magic links / OAuth callbacks)

    func handleDeepLink(_ url: URL) async {
        do {
            try await supabase.auth.session(from: url)
            await checkSession()
        } catch {
            print("Deep link auth error: \(error)")
        }
    }
}
