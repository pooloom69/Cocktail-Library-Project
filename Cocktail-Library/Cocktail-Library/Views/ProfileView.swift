//
//  ProfileView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 9/10/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var store: RecipeStore
    @EnvironmentObject var userSession: UserSession
    @State private var email = ""
    @State private var password = ""
    @State private var showCreateAccount = false
    @State private var userID = ""
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // MARK: - Header
                    Text(userSession.currentUser != nil ? "Profile" : "Welcome Back")
                        .font(AppTheme.titleFont())
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top, 40)

                    // MARK: - Logged In View
                    if let user = userSession.currentUser {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundColor(AppTheme.highlight)
                                .shadow(color: AppTheme.softShadow, radius: 5, y: 3)

                            Text(userSession.username.isEmpty ? (user.email ?? "User") : userSession.username)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("User ID: \(user.uid)")
                                .font(.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .padding(.horizontal)

                            Divider().background(AppTheme.divider)

                            Button(action: {
                                userSession.signOut()
                            }) {
                                Text("Sign Out")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.highlight)
                                    .cornerRadius(12)
                                    .shadow(color: AppTheme.softShadow, radius: 3, y: 2)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(20)
                        .shadow(color: AppTheme.softShadow, radius: 5, y: 3)
                        .padding(.horizontal)
                    }
                    // MARK: - Sign In View
                    else {
                        VStack(spacing: 18) {
                            Text("Sign In")
                                .font(.title2.bold())
                                .foregroundColor(AppTheme.textPrimary)

                            VStack(spacing: 12) {
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textFieldStyle(CustomTextFieldStyle())

                                SecureField("Password", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }

                            Button(action: {
                                signIn(email: email, password: password)
                            }) {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.highlight)
                                    .cornerRadius(12)
                                    .shadow(color: AppTheme.softShadow, radius: 3, y: 2)
                            }
                            .padding(.top, 8)

                            Button("Create Account") {
                                showCreateAccount = true
                            }
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 8)
                            .navigationDestination(isPresented: $showCreateAccount) {
                                CreateAccountView()
                                    .environmentObject(userSession)
                                    .environmentObject(store)
                            }
                        }
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(20)
                        .shadow(color: AppTheme.softShadow, radius: 5, y: 3)
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    // MARK: - Auth
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            if let user = result?.user {
                self.userID = user.uid
                self.isLoggedIn = true
                store.fetchUserRecipes(from: user.uid)
                store.fetchFavorites(from: user.uid)
            }
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(RecipeStore())
        .environmentObject(UserSession())
}

