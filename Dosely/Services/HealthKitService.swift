//
//  HealthKitService.swift
//  Dosely
//
//  Integrates with Apple Health for weight data sync
//

import Foundation
import HealthKit

@MainActor
class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    @Published var isAuthorized = false
    @Published var latestWeight: Double?

    private let healthStore = HKHealthStore()
    private let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!

    private init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit not available on this device")
            return
        }

        let typesToRead: Set<HKObjectType> = [weightType]
        let typesToWrite: Set<HKSampleType> = [weightType]

        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    print("✅ HealthKit authorized")
                } else if let error = error {
                    print("❌ HealthKit authorization error: \(error)")
                }
            }
        }
    }

    private func checkAuthorization() {
        let status = healthStore.authorizationStatus(for: weightType)
        isAuthorized = (status == .sharingAuthorized)
    }

    // MARK: - Read Weight Data

    func fetchLatestWeight() async throws -> Double? {
        guard isAuthorized else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                continuation.resume(returning: weightInKg)
            }

            healthStore.execute(query)
        }
    }

    func fetchWeightHistory(from startDate: Date, to endDate: Date) async throws -> [(date: Date, weight: Double)] {
        guard isAuthorized else { return [] }

        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: .strictStartDate
            )

            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let weightData = samples.map { sample in
                    (
                        date: sample.startDate,
                        weight: sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    )
                }

                continuation.resume(returning: weightData)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Write Weight Data

    func saveWeight(_ weightKg: Double, date: Date = Date()) async throws {
        guard isAuthorized else {
            throw NSError(domain: "HealthKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit not authorized"])
        }

        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weightKg)
        let sample = HKQuantitySample(
            type: weightType,
            quantity: quantity,
            start: date,
            end: date
        )

        try await healthStore.save(sample)
        print("✅ Weight saved to HealthKit: \(weightKg) kg")
    }

    // MARK: - Sync with App Data

    func syncWeightFromHealthKit(userId: UUID) async throws -> [WeightEntry] {
        guard isAuthorized else { return [] }

        // Fetch weight history from last 90 days
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -90, to: endDate) ?? endDate

        let healthKitData = try await fetchWeightHistory(from: startDate, to: endDate)

        // Convert to WeightEntry
        let entries = healthKitData.map { data in
            WeightEntry(
                id: UUID(),
                userId: userId,
                date: data.date,
                weightKg: data.weight,
                notes: nil,
                source: .healthKit,
                createdAt: Date()
            )
        }

        return entries
    }

    func enableBackgroundSync() {
        guard isAuthorized else { return }

        // Enable background delivery for weight updates
        healthStore.enableBackgroundDelivery(for: weightType, frequency: .immediate) { success, error in
            if success {
                print("✅ Background weight sync enabled")
            } else if let error = error {
                print("❌ Background sync error: \(error)")
            }
        }
    }
}
