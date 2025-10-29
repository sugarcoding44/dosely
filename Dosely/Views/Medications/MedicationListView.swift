//
//  MedicationListView.swift
//  Dosely
//

import SwiftUI

struct MedicationListView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var notificationService: NotificationService

    @State private var medications: [Medication] = []
    @State private var showAddMedication = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            List {
                if medications.isEmpty {
                    ContentUnavailableView(
                        "No Medications",
                        systemImage: "pills",
                        description: Text("Add your first medication to get started")
                    )
                } else {
                    ForEach(medications) { medication in
                        MedicationCard(medication: medication)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteMedication)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddMedication = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddMedication) {
                AddMedicationView(onAdd: { medication in
                    Task {
                        await addMedication(medication)
                    }
                })
            }
        }
        .task {
            await loadMedications()
        }
        .refreshable {
            await loadMedications()
        }
    }

    // MARK: - Data Operations

    private func loadMedications() async {
        guard let userId = authService.currentUser?.id else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            medications = try await SupabaseService.shared.getMedications(userId: userId)
        } catch {
            print("❌ Error loading medications: \(error)")
        }
    }

    private func addMedication(_ medication: Medication) async {
        do {
            try await SupabaseService.shared.addMedication(medication)
            await loadMedications()

            // Schedule notification
            try? await notificationService.scheduleRecurringReminder(
                medication: medication,
                time: Date(),
                frequencyDays: medication.frequencyDays
            )
        } catch {
            print("❌ Error adding medication: \(error)")
        }
    }

    private func deleteMedication(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let medication = medications[index]

                do {
                    try await SupabaseService.shared.deleteMedication(id: medication.id)
                    await notificationService.cancelReminders(for: medication.id)
                    await loadMedications()
                } catch {
                    print("❌ Error deleting medication: \(error)")
                }
            }
        }
    }
}

// MARK: - Medication Card

struct MedicationCard: View {
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(medication.name)
                        .font(.headline)

                    Text(medication.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.4, green: 0.49, blue: 0.92).opacity(0.2))
                        .foregroundColor(Color(red: 0.4, green: 0.49, blue: 0.92))
                        .cornerRadius(8)
                }

                Spacer()

                if medication.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }

            Divider()

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dose")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(medication.doseMg, specifier: "%.1f")mg")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Frequency")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Every \(medication.frequencyDays) days")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()
            }

            if let notes = medication.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    MedicationListView()
        .environmentObject(AuthService.shared)
        .environmentObject(NotificationService.shared)
}
