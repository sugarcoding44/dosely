//
//  DoselyApp.swift
//  Dosely
//
//  GLP-1 Medication & Weight Tracker
//

import SwiftUI
import UserNotifications

@main
struct DoselyApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var healthKitService = HealthKitService.shared
    @StateObject private var notificationService = NotificationService.shared

    init() {
        // Configure app appearance
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(healthKitService)
                .environmentObject(notificationService)
                .onAppear {
                    requestPermissions()
                }
        }
    }

    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func requestPermissions() {
        // Request notification permissions
        notificationService.requestAuthorization()

        // Request HealthKit permissions
        healthKitService.requestAuthorization()
    }
}
