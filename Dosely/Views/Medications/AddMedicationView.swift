//
//  AddMedicationView.swift
//  Dosely
//

import SwiftUI

struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService

    var onAdd: (Medication) -> Void

    @State private var name = ""
    @State private var doseMg = ""
    @State private var frequencyDays = "7"
    @State private var startDate = Date()
    @State private var medicationType: MedicationType = .glp1
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Medication Details") {
                    TextField("Name", text: $name)
                    TextField("Dose (mg)", text: $doseMg)
                        .keyboardType(.decimalPad)

                    Picker("Type", selection: $medicationType) {
                        ForEach(MedicationType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Schedule") {
                    Stepper("Every \(frequencyDays) days", value: Binding(
                        get: { Int(frequencyDays) ?? 7 },
                        set: { frequencyDays = String($0) }
                    ), in: 1...30)

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addMedication()
                    }
                    .disabled(name.isEmpty || doseMg.isEmpty)
                }
            }
        }
    }

    private func addMedication() {
        guard let userId = authService.currentUser?.id,
              let dose = Double(doseMg),
              let frequency = Int(frequencyDays) else {
            return
        }

        let medication = Medication(
            id: UUID(),
            userId: userId,
            name: name,
            doseMg: dose,
            frequencyDays: frequency,
            startDate: startDate,
            endDate: nil,
            type: medicationType,
            notes: notes.isEmpty ? nil : notes,
            createdAt: Date()
        )

        onAdd(medication)
        dismiss()
    }
}

#Preview {
    AddMedicationView(onAdd: { _ in })
        .environmentObject(AuthService.shared)
}
