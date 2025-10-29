//
//  ProfileView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 9/10/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var userID = ""
    @State private var showCreateAccount = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isLoggedIn {
                    VStack(spacing: 12) {
                        Text("Welcome, \(email)")
                            .font(.title2)
                        Text("User ID: \(userID)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Button("Sign Out") {
                            signOut()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Sign In")
                            .font(.largeTitle)
                            .bold()
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Sign In") {
                            signIn(email: email, password: password)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 10)
                        
                        Button("Create Account") {
                            showCreateAccount = true
                        }
                    }
                    .padding()
                    .navigationDestination(isPresented: $showCreateAccount) {
                        CreateAccountView()
                    }
                }
            }
            .padding()
        }
    }
}

extension ProfileView {
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(" Sign in failed: \(error.localizedDescription)")
                return
            }
            if let user = result?.user {
                self.userID = user.uid
                self.isLoggedIn = true
                print(" Signed in: \(user.email ?? "") (UID: \(user.uid))")
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            email = ""
            password = ""
            userID = ""
            print(" Signed out")
        } catch {
            print(" Sign out error:", error.localizedDescription)
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
