//
//  OnboardingView.swift
//  Dosely
//
//  Initial setup for new users
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authService: AuthService
    @State private var currentStep = 0
    @State private var username = ""
    @State private var measurementUnit: MeasurementUnit = .metric
    @State private var currentWeight = ""
    @State private var goalWeight = ""
    @State private var height = ""
    @State private var age = ""
    @State private var medication = "Ozempic"
    @State private var isLoading = false

    let medications = ["Ozempic", "Wegovy", "Mounjaro", "Saxenda", "Other"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.49, blue: 0.92),
                    Color(red: 0.46, green: 0.29, blue: 0.64)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Progress bar
                ProgressView(value: Double(currentStep + 1), total: 5)
                    .tint(.white)
                    .padding()

                ScrollView {
                    VStack(spacing: 30) {
                        switch currentStep {
                        case 0:
                            Step1View(username: $username)
                        case 1:
                            Step2View(measurementUnit: $measurementUnit)
                        case 2:
                            Step3View(currentWeight: $currentWeight, height: $height, age: $age, unit: measurementUnit)
                        case 3:
                            Step4View(goalWeight: $goalWeight, unit: measurementUnit)
                        case 4:
                            Step5View(medication: $medication, medications: medications)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }

                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }

                    Button(action: handleNext) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(currentStep < 4 ? "Next" : "Complete")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.49, blue: 0.92))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 10)
                    .disabled(isLoading)
                }
                .padding()
            }
        }
    }

    private func handleNext() {
        if currentStep < 4 {
            withAnimation {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        isLoading = true

        let profile = UserProfile(
            username: username.isEmpty ? nil : username,
            measurementUnit: measurementUnit,
            currentWeight: Double(currentWeight),
            goalWeight: Double(goalWeight),
            height: Double(height),
            age: Int(age),
            startDate: Date(),
            medication: medication,
            titrationSchedule: nil
        )

        Task {
            _ = await authService.completeOnboarding(profile: profile)
            isLoading = false
        }
    }
}

// MARK: - Onboarding Steps

struct Step1View: View {
    @Binding var username: String

    var body: some View {
        VStack(spacing: 20) {
            Text("👋")
                .font(.system(size: 80))

            Text("Welcome to Dosely!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Let's set up your profile")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))

            VStack(alignment: .leading, spacing: 8) {
                Text("Choose a username (optional)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                TextField("username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.top, 20)
        }
    }
}

struct Step2View: View {
    @Binding var measurementUnit: MeasurementUnit

    var body: some View {
        VStack(spacing: 20) {
            Text("⚖️")
                .font(.system(size: 80))

            Text("Measurement Unit")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Choose your preferred unit")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))

            VStack(spacing: 12) {
                Button(action: { measurementUnit = .metric }) {
                    HStack {
                        Text("Metric (kg, cm)")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        if measurementUnit == .metric {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(measurementUnit == .metric ? Color.white : Color.white.opacity(0.2))
                    .foregroundColor(measurementUnit == .metric ? Color(red: 0.4, green: 0.49, blue: 0.92) : .white)
                    .cornerRadius(12)
                }

                Button(action: { measurementUnit = .imperial }) {
                    HStack {
                        Text("Imperial (lbs, in)")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        if measurementUnit == .imperial {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(measurementUnit == .imperial ? Color.white : Color.white.opacity(0.2))
                    .foregroundColor(measurementUnit == .imperial ? Color(red: 0.4, green: 0.49, blue: 0.92) : .white)
                    .cornerRadius(12)
                }
            }
            .padding(.top, 20)
        }
    }
}

struct Step3View: View {
    @Binding var currentWeight: String
    @Binding var height: String
    @Binding var age: String
    let unit: MeasurementUnit

    var body: some View {
        VStack(spacing: 20) {
            Text("📊")
                .font(.system(size: 80))

            Text("Current Stats")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Weight (\(unit.weightUnit))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    TextField("75.0", text: $currentWeight)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Height (\(unit.heightUnit))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    TextField(unit == .metric ? "170" : "67", text: $height)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    TextField("30", text: $age)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 20)
        }
    }
}

struct Step4View: View {
    @Binding var goalWeight: String
    let unit: MeasurementUnit

    var body: some View {
        VStack(spacing: 20) {
            Text("🎯")
                .font(.system(size: 80))

            Text("Goal Weight")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("What's your target weight?")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))

            VStack(alignment: .leading, spacing: 8) {
                Text("Goal Weight (\(unit.weightUnit))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                TextField("65.0", text: $goalWeight)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.top, 20)
        }
    }
}

struct Step5View: View {
    @Binding var medication: String
    let medications: [String]

    var body: some View {
        VStack(spacing: 20) {
            Text("💊")
                .font(.system(size: 80))

            Text("Your Medication")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Which GLP-1 are you taking?")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))

            VStack(spacing: 12) {
                ForEach(medications, id: \.self) { med in
                    Button(action: { medication = med }) {
                        HStack {
                            Text(med)
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                            if medication == med {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(medication == med ? Color.white : Color.white.opacity(0.2))
                        .foregroundColor(medication == med ? Color(red: 0.4, green: 0.49, blue: 0.92) : .white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthService.shared)
}
