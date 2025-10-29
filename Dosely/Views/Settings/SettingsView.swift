//
//  SettingsView.swift
//  Dosely
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var healthKitService: HealthKitService
    @EnvironmentObject var notificationService: NotificationService

    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack {
                        Text("💊")
                            .font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 4) {
                            if let username = authService.currentUser?.profile?.username {
                                Text(username)
                                    .font(.headline)
                            }

                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // Preferences
                Section("Preferences") {
                    NavigationLink {
                        ProfileSettingsView()
                    } label: {
                        Label("Profile", systemImage: "person.fill")
                    }

                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        HStack {
                            Label("Notifications", systemImage: "bell.fill")
                            Spacer()
                            if notificationService.isAuthorized {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    NavigationLink {
                        HealthKitSettingsView()
                    } label: {
                        HStack {
                            Label("Apple Health", systemImage: "heart.fill")
                            Spacer()
                            if healthKitService.isAuthorized {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

                // App Info
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }

                // Logout
                Section {
                    Button(role: .destructive, action: { showLogoutAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    Task {
                        await authService.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

// MARK: - Profile Settings

struct ProfileSettingsView: View {
    @EnvironmentObject var authService: AuthService

    @State private var username: String = ""
    @State private var measurementUnit: MeasurementUnit = .metric
    @State private var goalWeight: String = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Username", text: $username)
            }

            Section("Preferences") {
                Picker("Measurement Unit", selection: $measurementUnit) {
                    Text("Metric (kg, cm)").tag(MeasurementUnit.metric)
                    Text("Imperial (lbs, in)").tag(MeasurementUnit.imperial)
                }

                HStack {
                    Text("Goal Weight")
                    Spacer()
                    TextField("Goal", text: $goalWeight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text(measurementUnit.weightUnit)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Button("Save Changes") {
                    saveProfile()
                }
                .frame(maxWidth: .infinity)
                .disabled(isSaving)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfile()
        }
    }

    private func loadProfile() {
        guard let profile = authService.currentUser?.profile else { return }

        username = profile.username ?? ""
        measurementUnit = profile.measurementUnit
        if let goal = profile.goalWeight {
            let displayGoal = measurementUnit == .metric ? goal : goal * 2.20462
            goalWeight = String(format: "%.1f", displayGoal)
        }
    }

    private func saveProfile() {
        isSaving = true

        var profile = authService.currentUser?.profile ?? UserProfile(
            measurementUnit: measurementUnit
        )

        profile.username = username.isEmpty ? nil : username
        profile.measurementUnit = measurementUnit

        if let goal = Double(goalWeight) {
            // Convert to kg if imperial
            profile.goalWeight = measurementUnit == .metric ? goal : goal / 2.20462
        }

        Task {
            _ = await authService.updateProfile(profile)
            isSaving = false
        }
    }
}

// MARK: - Notification Settings

struct NotificationSettingsView: View {
    @EnvironmentObject var notificationService: NotificationService

    var body: some View {
        List {
            Section {
                if notificationService.isAuthorized {
                    Label("Notifications Enabled", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Notifications Disabled", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }

            Section("About Notifications") {
                Text("Dosely uses notifications to remind you when it's time to take your medication.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !notificationService.isAuthorized {
                    Button("Enable Notifications") {
                        notificationService.requestAuthorization()
                    }
                }
            }

            Section {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - HealthKit Settings

struct HealthKitSettingsView: View {
    @EnvironmentObject var healthKitService: HealthKitService

    var body: some View {
        List {
            Section {
                if healthKitService.isAuthorized {
                    Label("Apple Health Connected", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Not Connected", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }

            Section("About Apple Health") {
                Text("Connect with Apple Health to automatically sync your weight data and track your progress.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !healthKitService.isAuthorized {
                    Button("Connect Apple Health") {
                        healthKitService.requestAuthorization()
                    }
                }
            }

            Section("Features") {
                Label("Automatic Weight Sync", systemImage: "arrow.triangle.2.circlepath")
                Label("Weight History Import", systemImage: "clock.arrow.circlepath")
                Label("Background Updates", systemImage: "bell.badge.fill")
            }
        }
        .navigationTitle("Apple Health")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService.shared)
        .environmentObject(HealthKitService.shared)
        .environmentObject(NotificationService.shared)
}
