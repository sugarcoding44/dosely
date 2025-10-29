//
//  LoginView.swift
//  Dosely
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var isSignUp: Bool

    @State private var emailOrUsername = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome Back")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                // Email or Username
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email or Username")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    TextField("your@email.com or username", text: $emailOrUsername)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    SecureField("••••••••", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Forgot password
                HStack {
                    Spacer()
                    Button("Forgot password?") {
                        showForgotPassword = true
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                }

                // Sign in button
                Button(action: handleSignIn) {
                    if authService.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.49, blue: 0.92),
                            Color(red: 0.46, green: 0.29, blue: 0.64)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                .disabled(authService.isLoading)

                // Toggle to sign up
                HStack {
                    Spacer()
                    Text("Don't have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    Button("Sign Up") {
                        isSignUp = true
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.49, blue: 0.92))
                    Spacer()
                }
            }
            .padding(25)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "Unknown error")
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }

    private func handleSignIn() {
        Task {
            let success: Bool
            if emailOrUsername.contains("@") {
                success = await authService.signIn(email: emailOrUsername, password: password)
            } else {
                success = await authService.signInWithUsername(emailOrUsername, password: password)
            }

            if !success {
                showError = true
            }
        }
    }
}

#Preview {
    LoginView(isSignUp: .constant(false))
        .environmentObject(AuthService.shared)
}
