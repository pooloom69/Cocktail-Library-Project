//
//  RecipeStore.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 2025-10-20.
//

import Foundation
import CocktailCore

@MainActor
final class RecipeStore: ObservableObject {
    // Published arrays so SwiftUI views automatically update when data changes
    @Published var defaultRecipes: [Recipe] = []   // Read-only, from CocktailCore package
    @Published var userRecipes: [Recipe] = []      // Read/write, stored in Documents folder
    
    init() {
        // Load both sets of recipes when the app starts
        loadDefaultRecipes()
        loadUserRecipes()
        
        // 🧭 Debug info
        if let url = getUserRecipesURL() {
            print("📂 User recipe file:", url)
        }
        print("📦 Default recipes:", defaultRecipes.count)
        print("👤 User recipes:", userRecipes.count)
    }
    
    // MARK: - Load default recipes (from CocktailCore package)
    func loadDefaultRecipes() {
        defaultRecipes = RecipeLoader.loadDefaultRecipes()
        print("📦 Loaded \(defaultRecipes.count) default recipes from CocktailCore package")
    }

    // MARK: - Load user recipes (from Documents directory)
    func loadUserRecipes() {
        guard let url = getUserRecipesURL() else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Recipe].self, from: data)
            userRecipes = decoded
            print("👤 Loaded \(userRecipes.count) user recipes from file.")
        } catch {
            print("⚠️ No user recipes found or failed to decode:", error)
            userRecipes = []
        }
    }
    
    // MARK: - Add a new user recipe
    func addUserRecipe(_ recipe: Recipe) {
        userRecipes.append(recipe)
        saveUserRecipes()
    }
    
    // MARK: - Save user recipes to Documents directory
    func saveUserRecipes() {
        guard let url = getUserRecipesURL() else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(userRecipes)
            try data.write(to: url, options: .atomic)
            
            print("💾 Saved \(userRecipes.count) user recipes → \(url.lastPathComponent)")
            print("📂 File location:", url.path)
        } catch {
            print("❌ Failed to save user recipes:", error)
        }
    }

    // MARK: - Delete recipe(s)
    func deleteUserRecipe(at offsets: IndexSet) {
        userRecipes.remove(atOffsets: offsets)
        saveUserRecipes()
        print("🗑️ Deleted recipe at index:", offsets)
        print("📊 Remaining user recipes:", userRecipes.count)
    }
    
    // MARK: - Helper: Path for user_recipes.json
    private func getUserRecipesURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("user_recipes.json")
    }
}
