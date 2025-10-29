//
//  DashboardView.swift
//  Dosely
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var healthKitService: HealthKitService

    @State private var medications: [Medication] = []
    @State private var recentDoses: [Dose] = []
    @State private var weightEntries: [WeightEntry] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let username = authService.currentUser?.profile?.username {
                                Text(username)
                                    .font(.title)
                                    .fontWeight(.bold)
                            } else {
                                Text("User")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                        Spacer()

                        Text("💊")
                            .font(.system(size: 50))
                    }
                    .padding()

                    // Stats cards
                    statsSection

                    // Weight chart
                    if !weightEntries.isEmpty {
                        weightChartSection
                    }

                    // Recent doses
                    recentDosesSection

                    // Next dose reminder
                    if !medications.isEmpty {
                        nextDoseSection
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await loadData()
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: - Sections

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            StatCard(
                title: "Current Weight",
                value: currentWeightDisplay,
                icon: "scalemass.fill",
                color: .blue
            )

            StatCard(
                title: "Goal Weight",
                value: goalWeightDisplay,
                icon: "target",
                color: .green
            )

            StatCard(
                title: "Weight Lost",
                value: weightLostDisplay,
                icon: "arrow.down.circle.fill",
                color: .red
            )

            StatCard(
                title: "Active Meds",
                value: "\(medications.filter { $0.isActive }.count)",
                icon: "pills.fill",
                color: .purple
            )
        }
        .padding(.horizontal)
    }

    private var weightChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Progress")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(weightEntries.prefix(30).reversed()) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weightKg)
                    )
                    .foregroundStyle(Color(red: 0.4, green: 0.49, blue: 0.92))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weightKg)
                    )
                    .foregroundStyle(Color(red: 0.4, green: 0.49, blue: 0.92))
                }
            }
            .frame(height: 200)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
            .padding(.horizontal)
        }
    }

    private var recentDosesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Doses")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    Text("All Doses")
                }
                .font(.subheadline)
            }
            .padding(.horizontal)

            if recentDoses.isEmpty {
                Text("No doses recorded yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(recentDoses.prefix(5)) { dose in
                    DoseRow(dose: dose)
                }
            }
        }
    }

    private var nextDoseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next Dose")
                .font(.headline)
                .padding(.horizontal)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if let med = medications.first(where: { $0.isActive }) {
                        Text(med.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("\(med.doseMg, specifier: "%.1f")mg")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Every \(med.frequencyDays) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()

                Image(systemName: "bell.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.4, green: 0.49, blue: 0.92))
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }

    // MARK: - Computed Properties

    private var currentWeightDisplay: String {
        guard let profile = authService.currentUser?.profile,
              let weight = weightEntries.first?.weightKg else {
            return "--"
        }
        let displayWeight = profile.measurementUnit == .metric ? weight : weight * 2.20462
        return String(format: "%.1f", displayWeight)
    }

    private var goalWeightDisplay: String {
        guard let profile = authService.currentUser?.profile,
              let goalWeight = profile.goalWeight else {
            return "--"
        }
        let displayWeight = profile.measurementUnit == .metric ? goalWeight : goalWeight * 2.20462
        return String(format: "%.1f", displayWeight)
    }

    private var weightLostDisplay: String {
        guard let profile = authService.currentUser?.profile,
              let currentWeight = weightEntries.first?.weightKg,
              let startWeight = profile.currentWeight else {
            return "--"
        }
        let lost = startWeight - currentWeight
        let displayLost = profile.measurementUnit == .metric ? lost : lost * 2.20462
        return String(format: "%.1f", displayLost)
    }

    // MARK: - Data Loading

    private func loadData() async {
        guard let userId = authService.currentUser?.id else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let supabase = SupabaseService.shared

            // Load medications
            medications = try await supabase.getMedications(userId: userId)

            // Load recent doses
            recentDoses = try await supabase.getDoses(userId: userId)

            // Load weight entries
            weightEntries = try await supabase.getWeightEntries(userId: userId)

            // Try to sync with HealthKit
            if healthKitService.isAuthorized {
                if let latestWeight = try? await healthKitService.fetchLatestWeight() {
                    healthKitService.latestWeight = latestWeight
                }
            }
        } catch {
            print("❌ Error loading dashboard data: \(error)")
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Dose Row Component

struct DoseRow: View {
    let dose: Dose

    var body: some View {
        HStack {
            Image(systemName: dose.taken ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(dose.taken ? .green : .gray)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(dose.doseMg, specifier: "%.1f")mg")
                    .font(.headline)

                Text(dose.displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(dose.displayTime)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthService.shared)
        .environmentObject(HealthKitService.shared)
}
