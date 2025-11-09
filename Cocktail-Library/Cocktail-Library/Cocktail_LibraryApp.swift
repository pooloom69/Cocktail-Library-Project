//
//  Cocktail_LibraryApp.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 9/10/25.
//

import SwiftUI
import CocktailCore
import FirebaseCore
import FirebaseAuth

@main
struct Cocktail_LibraryApp: App {
    
    init(){
        FirebaseApp.configure()
        print("📄 Firebase plist path:", Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ?? "Not found")

        print("🔥 Firebase configured successfully")
        
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)
        appearance.backgroundColor = UIColor(AppTheme.tabBar)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

    }
    
    @StateObject private var store = RecipeStore()
    @StateObject private var userSession = UserSession()
    

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .environmentObject(userSession)
                .onChange(of: userSession.currentUser) { oldUser, newUser in
                                    if let user = newUser {
                                        store.fetchUserRecipes(from: user.uid)
                                        store.fetchFavorites(from: user.uid)
                                        print("✅ Synced Firestore data for:", user.email ?? user.uid)
                                    } else {
                                        store.userRecipes = []
                                        store.favoriteRecipes = []
                                        print("🚪 User signed out — cleared local data.")
                                    }
                                }
            
                                //  Also load data immediately if user is already logged in
                                .onAppear {
                                    if let user = userSession.currentUser {
                                        store.fetchUserRecipes(from: user.uid)
                                        store.fetchFavorites(from: user.uid)
                                        print("🔁 Loaded Firestore data for existing user:", user.email ?? user.uid)
                                    }
                                }
                }
        }
}
