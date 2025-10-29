//
//  NotificationService.swift
//  Dosely
//
//  Manages local notifications for medication reminders
//

import Foundation
import UserNotifications

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted

                if granted {
                    print("✅ Notification authorization granted")
                } else if let error = error {
                    print("❌ Notification authorization error: \(error)")
                }
            }
        }
    }

    private func checkAuthorization() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Schedule Notifications

    func scheduleDoseReminder(
        medication: Medication,
        doseDate: Date,
        doseTime: Date
    ) async throws {
        guard isAuthorized else {
            throw NSError(domain: "NotificationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notifications not authorized"])
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for your medication 💊"
        content.body = "\(medication.name) - \(medication.doseMg)mg"
        content.sound = .default
        content.badge = 1

        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: doseDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: doseTime)

        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Create request
        let identifier = "dose-\(medication.id.uuidString)-\(doseDate.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule
        try await notificationCenter.add(request)
        print("✅ Dose reminder scheduled for \(components)")
    }

    func scheduleRecurringReminder(
        medication: Medication,
        time: Date,
        frequencyDays: Int
    ) async throws {
        guard isAuthorized else {
            throw NSError(domain: "NotificationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notifications not authorized"])
        }

        // Cancel existing reminders for this medication
        await cancelReminders(for: medication.id)

        // Schedule next 10 doses
        let calendar = Calendar.current
        var currentDate = medication.startDate

        for i in 0..<10 {
            let doseDate = calendar.date(byAdding: .day, value: i * frequencyDays, to: currentDate) ?? currentDate

            // Only schedule future reminders
            if doseDate > Date() {
                try await scheduleDoseReminder(medication: medication, doseDate: doseDate, doseTime: time)
            }
        }
    }

    func cancelReminders(for medicationId: UUID) async {
        let identifierPrefix = "dose-\(medicationId.uuidString)"

        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let identifiersToCancel = pendingRequests
            .filter { $0.identifier.hasPrefix(identifierPrefix) }
            .map { $0.identifier }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        print("✅ Cancelled \(identifiersToCancel.count) reminders for medication \(medicationId)")
    }

    func cancelAllReminders() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        print("✅ All notifications cancelled")
    }

    // MARK: - Manage Notifications

    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Weight Reminder

    func scheduleWeightReminder(time: Date, weekdays: [Int]) async throws {
        guard isAuthorized else {
            throw NSError(domain: "NotificationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notifications not authorized"])
        }

        // Cancel existing weight reminders
        let identifiersToCancel = ["weight-reminder"]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)

        let content = UNMutableNotificationContent()
        content.title = "Don't forget to log your weight! ⚖️"
        content.body = "Track your progress today"
        content.sound = .default

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        // Schedule for each weekday
        for weekday in weekdays {
            var components = DateComponents()
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.weekday = weekday // 1 = Sunday, 2 = Monday, etc.

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let identifier = "weight-reminder-\(weekday)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            try await notificationCenter.add(request)
        }

        print("✅ Weight reminders scheduled for weekdays: \(weekdays)")
    }
}
