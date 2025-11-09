//
//  CreateAccountView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 10/25/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var username = ""

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 22) {
                    // MARK: – Header
                    Text("Create Account")
                        .font(AppTheme.titleFont())
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top, 40)
                    
                    Text("Join our library of creative cocktails.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.bottom, 8)
                    
                    // MARK: – Input Fields
                    VStack(spacing: 14) {
                        TextField("Email", text: $newEmail)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        TextField("Username", text: $username)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        SecureField("Password", text: $newPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    .padding(.top, 8)
                    
                    // MARK: – Sign Up Button
                    Button {
                        createAccount()
                    } label: {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.highlight)
                            .cornerRadius(12)
                            .shadow(color: AppTheme.softShadow, radius: 3, y: 2)
                    }
                    .padding(.top, 10)
                    
                    // MARK: – Message
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }

    // MARK: – Account Creation Logic
    func createAccount() {
        guard !newEmail.isEmpty, !newPassword.isEmpty, !username.isEmpty else {
            message = "Please fill in all fields."
            return
        }
        guard newPassword == confirmPassword else {
            message = "Passwords do not match."
            return
        }

        Auth.auth().createUser(withEmail: newEmail, password: newPassword) { result, error in
            if let error = error {
                message = "❌ \(error.localizedDescription)"
                return
            }
            guard let user = result?.user else { return }

            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "username": username,
                "email": newEmail,
                "createdAt": FieldValue.serverTimestamp()
            ]

            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("❌ Error saving user data:", error.localizedDescription)
                    message = "Failed to save user info."
                } else {
                    print("✅ User profile saved for \(username)")
                    message = "Account created successfully!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
