//
//  Medication.swift
//  Dosely
//

import Foundation

struct Medication: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let doseMg: Double
    let frequencyDays: Int
    let startDate: Date
    var endDate: Date?
    let type: MedicationType
    var notes: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case doseMg = "dose_mg"
        case frequencyDays = "frequency_days"
        case startDate = "start_date"
        case endDate = "end_date"
        case type, notes
        case createdAt = "created_at"
    }

    var isActive: Bool {
        if let endDate = endDate {
            return endDate > Date()
        }
        return true
    }
}

enum MedicationType: String, Codable, CaseIterable {
    case glp1 = "GLP-1"
    case other = "Other"

    var displayName: String {
        self.rawValue
    }
}
