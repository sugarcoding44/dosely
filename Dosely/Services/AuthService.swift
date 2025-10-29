//
//  AuthService.swift
//  Dosely
//

import Foundation
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var needsOnboarding = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabase = SupabaseService.shared

    private init() {}

    func checkSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let user = try await supabase.getCurrentSession() {
                currentUser = user

                // Load profile
                if let profile = try await supabase.getProfile(userId: user.id) {
                    var updatedUser = user
                    updatedUser.profile = profile
                    currentUser = updatedUser
                    needsOnboarding = false
                } else {
                    needsOnboarding = true
                }

                isAuthenticated = true
            } else {
                isAuthenticated = false
                currentUser = nil
            }
        } catch {
            print("❌ Error checking session: \(error)")
            isAuthenticated = false
            currentUser = nil
        }
    }

    func signUp(email: String, password: String, username: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await supabase.signUp(email: email, password: password, username: username)
            currentUser = user
            needsOnboarding = true
            isAuthenticated = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await supabase.signIn(email: email, password: password)
            currentUser = user

            // Check if profile exists
            if let profile = try await supabase.getProfile(userId: user.id) {
                var updatedUser = user
                updatedUser.profile = profile
                currentUser = updatedUser
                needsOnboarding = false
            } else {
                needsOnboarding = true
            }

            isAuthenticated = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signInWithUsername(_ username: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await supabase.signInWithUsername(username, password: password)
            currentUser = user

            // Check if profile exists
            if let profile = try await supabase.getProfile(userId: user.id) {
                var updatedUser = user
                updatedUser.profile = profile
                currentUser = updatedUser
                needsOnboarding = false
            } else {
                needsOnboarding = true
            }

            isAuthenticated = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signOut() async {
        do {
            try await supabase.signOut()
            isAuthenticated = false
            currentUser = nil
            needsOnboarding = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await supabase.resetPassword(email: email)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func completeOnboarding(profile: UserProfile) async -> Bool {
        guard let userId = currentUser?.id else { return false }

        do {
            try await supabase.updateProfile(userId: userId, profile: profile)
            var updatedUser = currentUser
            updatedUser?.profile = profile
            currentUser = updatedUser
            needsOnboarding = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateProfile(_ profile: UserProfile) async -> Bool {
        guard let userId = currentUser?.id else { return false }

        do {
            try await supabase.updateProfile(userId: userId, profile: profile)
            var updatedUser = currentUser
            updatedUser?.profile = profile
            currentUser = updatedUser
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
