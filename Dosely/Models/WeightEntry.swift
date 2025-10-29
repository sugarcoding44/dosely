//
//  WeightEntry.swift
//  Dosely
//

import Foundation

struct WeightEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let date: Date
    let weightKg: Double
    var notes: String?
    var source: WeightSource
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case weightKg = "weight_kg"
        case notes, source
        case createdAt = "created_at"
    }

    func weight(in unit: MeasurementUnit) -> Double {
        switch unit {
        case .metric:
            return weightKg
        case .imperial:
            return weightKg * 2.20462
        }
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum WeightSource: String, Codable {
    case manual
    case healthKit = "health_kit"
    case imported

    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .healthKit: return "Apple Health"
        case .imported: return "Imported"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "pencil"
        case .healthKit: return "heart.fill"
        case .imported: return "square.and.arrow.down"
        }
    }
}
