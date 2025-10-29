//
//  AuthView.swift
//  Dosely
//

import SwiftUI

struct AuthView: View {
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.49, blue: 0.92),
                    Color(red: 0.46, green: 0.29, blue: 0.64)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 60)

                    // Logo
                    VStack(spacing: 15) {
                        Text("💊")
                            .font(.system(size: 80))

                        Text("Dosely")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)

                        Text("Your GLP-1 Companion")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Auth card
                    if isSignUp {
                        SignUpView(isSignUp: $isSignUp)
                    } else {
                        LoginView(isSignUp: $isSignUp)
                    }

                    Spacer()
                        .frame(height: 40)

                    Text("Developed with ❤️")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthService.shared)
}
