//
//  ContentView.swift
//  Dosely
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                SplashView()
            } else if authService.isAuthenticated {
                if authService.needsOnboarding {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            } else {
                AuthView()
            }
        }
        .onAppear {
            checkAuthStatus()
        }
    }

    private func checkAuthStatus() {
        Task {
            await authService.checkSession()
            withAnimation {
                isLoading = false
            }
        }
    }
}

struct SplashView: View {
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

            VStack(spacing: 20) {
                Text("💊")
                    .font(.system(size: 80))

                Text("Dosely")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
                    .padding(.top, 20)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
        .environmentObject(HealthKitService.shared)
        .environmentObject(NotificationService.shared)
}
