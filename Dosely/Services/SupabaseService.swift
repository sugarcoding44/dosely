//
//  SupabaseService.swift
//  Dosely
//
//  Handles all Supabase interactions
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()

    // MARK: - Configuration
    private let supabaseURL = "https://wnjpxvzvktytrwenucbu.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InduanB4dnp2a3R5dHJ3ZW51Y2J1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2MzYwNjMsImV4cCI6MjA3NzIxMjA2M30.2F8Fxp74rcMRWNjdCOg1z13AmMDIsVmH-NFTTb4Aa70"

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }

    // MARK: - Authentication

    func signUp(email: String, password: String, username: String) async throws -> User {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["username": .string(username)]
        )

        guard let user = response.user else {
            throw NSError(domain: "SupabaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])
        }

        return User(
            id: UUID(uuidString: user.id.uuidString) ?? UUID(),
            email: user.email ?? email,
            profile: nil
        )
    }

    func signIn(email: String, password: String) async throws -> User {
        let response = try await client.auth.signIn(email: email, password: password)

        guard let user = response.user else {
            throw NSError(domain: "SupabaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])
        }

        return User(
            id: UUID(uuidString: user.id.uuidString) ?? UUID(),
            email: user.email ?? email,
            profile: nil
        )
    }

    func signInWithUsername(_ username: String, password: String) async throws -> User {
        // Look up email from username
        let response: [UserProfile] = try await client.database
            .from("profiles")
            .select()
            .eq("username", value: username)
            .limit(1)
            .execute()
            .value

        guard let profile = response.first,
              let email = profile.username else {
            throw NSError(domain: "SupabaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Username not found"])
        }

        return try await signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    func getCurrentSession() async throws -> User? {
        let session = try await client.auth.session

        guard let user = session.user else {
            return nil
        }

        return User(
            id: UUID(uuidString: user.id.uuidString) ?? UUID(),
            email: user.email ?? "",
            profile: nil
        )
    }

    // MARK: - Profile

    func getProfile(userId: UUID) async throws -> UserProfile? {
        let response: UserProfile? = try await client.database
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        return response
    }

    func updateProfile(userId: UUID, profile: UserProfile) async throws {
        try await client.database
            .from("profiles")
            .update(profile)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Medications

    func getMedications(userId: UUID) async throws -> [Medication] {
        let response: [Medication] = try await client.database
            .from("medications")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    func addMedication(_ medication: Medication) async throws {
        try await client.database
            .from("medications")
            .insert(medication)
            .execute()
    }

    func updateMedication(_ medication: Medication) async throws {
        try await client.database
            .from("medications")
            .update(medication)
            .eq("id", value: medication.id.uuidString)
            .execute()
    }

    func deleteMedication(id: UUID) async throws {
        try await client.database
            .from("medications")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Doses

    func getDoses(userId: UUID, startDate: Date? = nil, endDate: Date? = nil) async throws -> [Dose] {
        var query = client.database
            .from("doses")
            .select()
            .eq("user_id", value: userId.uuidString)

        if let startDate = startDate {
            query = query.gte("date", value: startDate.ISO8601Format())
        }

        if let endDate = endDate {
            query = query.lte("date", value: endDate.ISO8601Format())
        }

        let response: [Dose] = try await query
            .order("date", ascending: false)
            .execute()
            .value

        return response
    }

    func addDose(_ dose: Dose) async throws {
        try await client.database
            .from("doses")
            .insert(dose)
            .execute()
    }

    func updateDose(_ dose: Dose) async throws {
        try await client.database
            .from("doses")
            .update(dose)
            .eq("id", value: dose.id.uuidString)
            .execute()
    }

    func deleteDose(id: UUID) async throws {
        try await client.database
            .from("doses")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Weight Entries

    func getWeightEntries(userId: UUID, startDate: Date? = nil, endDate: Date? = nil) async throws -> [WeightEntry] {
        var query = client.database
            .from("weight_logs")
            .select()
            .eq("user_id", value: userId.uuidString)

        if let startDate = startDate {
            query = query.gte("date", value: startDate.ISO8601Format())
        }

        if let endDate = endDate {
            query = query.lte("date", value: endDate.ISO8601Format())
        }

        let response: [WeightEntry] = try await query
            .order("date", ascending: false)
            .execute()
            .value

        return response
    }

    func addWeightEntry(_ entry: WeightEntry) async throws {
        try await client.database
            .from("weight_logs")
            .insert(entry)
            .execute()
    }

    func updateWeightEntry(_ entry: WeightEntry) async throws {
        try await client.database
            .from("weight_logs")
            .update(entry)
            .eq("id", value: entry.id.uuidString)
            .execute()
    }

    func deleteWeightEntry(id: UUID) async throws {
        try await client.database
            .from("weight_logs")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
