//
//  MainTabView.swift
//  Dosely
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            MedicationListView()
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(1)

            WeightLogView()
                .tabItem {
                    Label("Weight", systemImage: "scalemass.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.4, green: 0.49, blue: 0.92))
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService.shared)
        .environmentObject(HealthKitService.shared)
        .environmentObject(NotificationService.shared)
}
