//
//  WeightLogView.swift
//  Dosely
//

import SwiftUI
import Charts

struct WeightLogView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var healthKitService: HealthKitService

    @State private var weightEntries: [WeightEntry] = []
    @State private var showAddWeight = false
    @State private var isLoading = false
    @State private var showSyncSheet = false

    var measurementUnit: MeasurementUnit {
        authService.currentUser?.profile?.measurementUnit ?? .metric
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Chart
                    if !weightEntries.isEmpty {
                        weightChartSection
                    }

                    // Stats
                    statsSection

                    // HealthKit Sync
                    healthKitSection

                    // Weight entries list
                    weightEntriesSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Weight Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddWeight = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddWeight) {
                AddWeightView(onAdd: { entry in
                    Task {
                        await addWeightEntry(entry)
                    }
                })
            }
            .sheet(isPresented: $showSyncSheet) {
                HealthKitSyncView(onSync: {
                    Task {
                        await syncWithHealthKit()
                    }
                })
            }
        }
        .task {
            await loadWeightEntries()
        }
        .refreshable {
            await loadWeightEntries()
        }
    }

    // MARK: - Sections

    private var weightChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(weightEntries.prefix(90).reversed()) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight(in: measurementUnit))
                    )
                    .foregroundStyle(Color(red: 0.4, green: 0.49, blue: 0.92))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight(in: measurementUnit))
                    )
                    .foregroundStyle(Color(red: 0.4, green: 0.49, blue: 0.92))
                }

                // Goal line
                if let goalWeight = authService.currentUser?.profile?.goalWeight {
                    let displayGoal = measurementUnit == .metric ? goalWeight : goalWeight * 2.20462
                    RuleMark(y: .value("Goal", displayGoal))
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Goal")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                }
            }
            .frame(height: 250)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
            .padding(.horizontal)
        }
    }

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            StatCard(
                title: "Current",
                value: currentWeightDisplay,
                icon: "scalemass.fill",
                color: .blue
            )

            StatCard(
                title: "Start",
                value: startWeightDisplay,
                icon: "flag.fill",
                color: .orange
            )

            StatCard(
                title: "Lost",
                value: weightLostDisplay,
                icon: "arrow.down.circle.fill",
                color: .red
            )

            StatCard(
                title: "To Goal",
                value: weightToGoalDisplay,
                icon: "target",
                color: .green
            )
        }
        .padding(.horizontal)
    }

    private var healthKitSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Health")
                        .font(.headline)

                    if healthKitService.isAuthorized {
                        Text("Connected")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Not Connected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button(action: { showSyncSheet = true }) {
                    Text("Sync")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.4, green: 0.49, blue: 0.92))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
            .padding(.horizontal)
        }
    }

    private var weightEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.headline)
                .padding(.horizontal)

            if weightEntries.isEmpty {
                Text("No weight entries yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(weightEntries) { entry in
                    WeightEntryRow(entry: entry, unit: measurementUnit)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var currentWeightDisplay: String {
        guard let latest = weightEntries.first else { return "--" }
        return String(format: "%.1f %@", latest.weight(in: measurementUnit), measurementUnit.weightUnit)
    }

    private var startWeightDisplay: String {
        guard let start = weightEntries.last else { return "--" }
        return String(format: "%.1f %@", start.weight(in: measurementUnit), measurementUnit.weightUnit)
    }

    private var weightLostDisplay: String {
        guard let latest = weightEntries.first,
              let start = weightEntries.last else { return "--" }
        let lost = start.weightKg - latest.weightKg
        let displayLost = measurementUnit == .metric ? lost : lost * 2.20462
        return String(format: "%.1f %@", displayLost, measurementUnit.weightUnit)
    }

    private var weightToGoalDisplay: String {
        guard let latest = weightEntries.first,
              let goalWeight = authService.currentUser?.profile?.goalWeight else { return "--" }
        let toGo = latest.weightKg - goalWeight
        let displayToGo = measurementUnit == .metric ? toGo : toGo * 2.20462
        return String(format: "%.1f %@", displayToGo, measurementUnit.weightUnit)
    }

    // MARK: - Data Operations

    private func loadWeightEntries() async {
        guard let userId = authService.currentUser?.id else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            weightEntries = try await SupabaseService.shared.getWeightEntries(userId: userId)
        } catch {
            print("❌ Error loading weight entries: \(error)")
        }
    }

    private func addWeightEntry(_ entry: WeightEntry) async {
        do {
            try await SupabaseService.shared.addWeightEntry(entry)

            // Also save to HealthKit if authorized
            if healthKitService.isAuthorized {
                try? await healthKitService.saveWeight(entry.weightKg, date: entry.date)
            }

            await loadWeightEntries()
        } catch {
            print("❌ Error adding weight entry: \(error)")
        }
    }

    private func syncWithHealthKit() async {
        guard let userId = authService.currentUser?.id,
              healthKitService.isAuthorized else { return }

        do {
            let healthKitEntries = try await healthKitService.syncWeightFromHealthKit(userId: userId)

            // Add entries that don't exist
            for entry in healthKitEntries {
                try? await SupabaseService.shared.addWeightEntry(entry)
            }

            await loadWeightEntries()
        } catch {
            print("❌ Error syncing with HealthKit: \(error)")
        }
    }
}

// MARK: - Weight Entry Row

struct WeightEntryRow: View {
    let entry: WeightEntry
    let unit: MeasurementUnit

    var body: some View {
        HStack {
            Image(systemName: entry.source.icon)
                .foregroundColor(.blue)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.1f %@", entry.weight(in: unit), unit.weightUnit))
                    .font(.headline)

                Text(entry.displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(entry.source.displayName)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Add Weight View

struct AddWeightView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService

    var onAdd: (WeightEntry) -> Void

    @State private var weight = ""
    @State private var date = Date()
    @State private var notes = ""

    var measurementUnit: MeasurementUnit {
        authService.currentUser?.profile?.measurementUnit ?? .metric
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Weight") {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Text(measurementUnit.weightUnit)
                            .foregroundColor(.secondary)
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addWeight()
                    }
                    .disabled(weight.isEmpty)
                }
            }
        }
    }

    private func addWeight() {
        guard let userId = authService.currentUser?.id,
              var weightValue = Double(weight) else {
            return
        }

        // Convert to kg if imperial
        if measurementUnit == .imperial {
            weightValue = weightValue / 2.20462
        }

        let entry = WeightEntry(
            id: UUID(),
            userId: userId,
            date: date,
            weightKg: weightValue,
            notes: notes.isEmpty ? nil : notes,
            source: .manual,
            createdAt: Date()
        )

        onAdd(entry)
        dismiss()
    }
}

// MARK: - HealthKit Sync View

struct HealthKitSyncView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var healthKitService: HealthKitService

    var onSync: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.pink)

                VStack(spacing: 12) {
                    Text("Sync with Apple Health")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Import your weight data from Apple Health and keep it in sync")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                if !healthKitService.isAuthorized {
                    Button("Grant Access") {
                        healthKitService.requestAuthorization()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button("Sync Now") {
                    onSync()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!healthKitService.isAuthorized)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WeightLogView()
        .environmentObject(AuthService.shared)
        .environmentObject(HealthKitService.shared)
}
