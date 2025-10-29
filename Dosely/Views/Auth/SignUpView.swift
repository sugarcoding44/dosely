//
//  SignUpView.swift
//  Dosely
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var isSignUp: Bool

    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Create Account")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    TextField("your@email.com", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Username
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    TextField("username", text: $username)
                        .textContentType(.username)
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
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Confirm Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    SecureField("••••••••", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Sign up button
                Button(action: handleSignUp) {
                    if authService.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign Up")
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

                // Toggle to sign in
                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    Button("Sign In") {
                        isSignUp = false
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
            Text(errorMessage)
        }
    }

    private func handleSignUp() {
        // Validation
        guard !email.isEmpty, !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }

        Task {
            let success = await authService.signUp(email: email, password: password, username: username)

            if !success {
                errorMessage = authService.errorMessage ?? "Sign up failed"
                showError = true
            }
        }
    }
}

#Preview {
    SignUpView(isSignUp: .constant(true))
        .environmentObject(AuthService.shared)
}
