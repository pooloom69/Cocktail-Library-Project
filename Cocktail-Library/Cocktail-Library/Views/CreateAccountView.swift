//
//  CreateAccountView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 10/25/25.
//

import SwiftUI
import FirebaseAuth

struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $newEmail)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $newPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
            
            Button("Sign Up") {
                createAccount()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
        .padding()
    }

    func createAccount() {
        guard newPassword == confirmPassword else {
            message = "Passwords do not match"
            return
        }

        Auth.auth().createUser(withEmail: newEmail, password: newPassword) { result, error in
            if let error = error {
                message = "❌ \(error.localizedDescription)"
            } else if let user = result?.user {
                message = "✅ Account created for \(user.email ?? "")"
                dismiss()
            }
        }
    }
}

