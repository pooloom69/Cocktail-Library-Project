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
        
        
        
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("❌ Firebase Auth error:", error.localizedDescription)
            } else if let user = result?.user {
                print("✅ Firebase connected! UID:", user.uid)
            }
        }
    }
    
    @StateObject private var store = RecipeStore()
    

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store) 
        }
    }
}
