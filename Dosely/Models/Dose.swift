//
//  Dose.swift
//  Dosely
//

import Foundation

struct Dose: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let medicationId: UUID
    let date: Date
    let time: Date
    let doseMg: Double
    var taken: Bool
    var notes: String?
    var symptoms: [String]?
    var symptomSeverity: Int?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case medicationId = "medication_id"
        case date, time
        case doseMg = "dose_mg"
        case taken, notes, symptoms
        case symptomSeverity = "symptom_severity"
        case createdAt = "created_at"
    }

    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Common GLP-1 symptoms
extension Dose {
    static let commonSymptoms = [
        "Nausea",
        "Vomiting",
        "Diarrhea",
        "Constipation",
        "Headache",
        "Fatigue",
        "Dizziness",
        "Stomach pain",
        "Loss of appetite",
        "Heartburn"
    ]
}
