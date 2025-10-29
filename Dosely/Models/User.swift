//
//  User.swift
//  Dosely
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    var profile: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id, email, profile
    }
}

struct UserProfile: Codable {
    var username: String?
    var measurementUnit: MeasurementUnit
    var currentWeight: Double?
    var goalWeight: Double?
    var height: Double?
    var age: Int?
    var startDate: Date?
    var medication: String?
    var titrationSchedule: [TitrationWeek]?

    enum CodingKeys: String, CodingKey {
        case username
        case measurementUnit = "measurement_unit"
        case currentWeight = "current_weight"
        case goalWeight = "goal_weight"
        case height, age
        case startDate = "start_date"
        case medication
        case titrationSchedule = "titration_schedule"
    }
}

enum MeasurementUnit: String, Codable {
    case metric
    case imperial

    var weightUnit: String {
        switch self {
        case .metric: return "kg"
        case .imperial: return "lbs"
        }
    }

    var heightUnit: String {
        switch self {
        case .metric: return "cm"
        case .imperial: return "in"
        }
    }
}

struct TitrationWeek: Codable, Identifiable {
    var id: Int { week }
    let week: Int
    let doseMg: Double
    let frequencyDays: Int

    enum CodingKeys: String, CodingKey {
        case week
        case doseMg = "dose_mg"
        case frequencyDays = "frequency_days"
    }
}
