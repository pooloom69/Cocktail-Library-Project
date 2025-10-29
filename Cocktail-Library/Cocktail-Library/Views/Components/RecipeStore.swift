//
//  RecipeStore.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 2025-10-20.
//

import Foundation
import CocktailCore
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class RecipeStore: ObservableObject {
    // MARK: - Published data
    @Published var defaultRecipes: [Recipe] = []
    @Published var userRecipes: [Recipe] = []
    @Published var favoriteRecipes: [Recipe] = []

    // MARK: - Firestore reference
    private let db = Firestore.firestore()

    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Init
    init() {
        loadDefaultRecipes()
    }

    // MARK: - Load Data from Firestore
    func loadUserRecipes() {
        guard let uid = currentUserID else {
            print(" No logged-in user.")
            return
        }

        db.collection("users")
            .document(uid)
            .collection("userRecipes")
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Failed to load user recipes:", error.localizedDescription)
                    return
                }
                guard let docs = snapshot?.documents else {
                    print(" No user recipes found.")
                    return
                }

                self.userRecipes = docs.compactMap { doc in
                    try? doc.data(as: Recipe.self)
                }

                print(" Loaded \(self.userRecipes.count) user recipes from Firestore.")
            }
    }

    func loadFavoriteRecipes() {
        guard let uid = currentUserID else {
            print(" No logged-in user.")
            return
        }

        db.collection("users")
            .document(uid)
            .collection("favorites")
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Failed to load favorites:", error.localizedDescription)
                    return
                }
                guard let docs = snapshot?.documents else {
                    print(" No favorites found.")
                    return
                }

                self.favoriteRecipes = docs.compactMap { doc in
                    try? doc.data(as: Recipe.self)
                }

                print(" Loaded \(self.favoriteRecipes.count) favorites from Firestore.")
            }
    }

    // MARK: - Save Methods
    func addUserRecipe(_ recipe: Recipe) {
        guard let uid = currentUserID else {
            print(" No logged-in user.")
            return
        }

        let ref = db.collection("users")
            .document(uid)
            .collection("userRecipes")
            .document(recipe.id) // recipe.id가 String이면 그대로 사용

        do {
            try ref.setData(from: recipe)
            userRecipes.append(recipe)
            print(" Saved new recipe to Firestore.")
        } catch {
            print(" Error saving recipe:", error.localizedDescription)
        }
    }

    func toggleFavorite(_ recipe: Recipe) {
        guard let uid = currentUserID else {
            print(" No logged-in user.")
            return
        }

        let favRef = db.collection("users")
            .document(uid)
            .collection("favorites")
            .document(recipe.id)

        if let index = favoriteRecipes.firstIndex(where: { $0.id == recipe.id }) {
            // remove from favorites
            favoriteRecipes.remove(at: index)
            favRef.delete { error in
                if let error = error {
                    print(" Error removing favorite:", error.localizedDescription)
                } else {
                    print(" Removed from favorites.")
                }
            }
        } else {
            // add to favorites
            favoriteRecipes.append(recipe)
            do {
                try favRef.setData(from: recipe)
                print(" Added to favorites.")
            } catch {
                print(" Error adding favorite:", error.localizedDescription)
            }
        }
    }
    
    func deleteUserRecipe(at offsets: IndexSet) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print(" No logged-in user.")
            return
        }

        for index in offsets {
            let recipe = userRecipes[index]
            let docRef = db.collection("users")
                .document(uid)
                .collection("userRecipes")
                .document(recipe.id)

            docRef.delete { error in
                if let error = error {
                    print(" Error deleting recipe:", error.localizedDescription)
                } else {
                    print(" Deleted recipe from Firestore:", recipe.name)
                }
            }
        }

        userRecipes.remove(atOffsets: offsets)
    }


    func isFavorite(_ recipe: Recipe) -> Bool {
        favoriteRecipes.contains(where: { $0.id == recipe.id })
    }

    // MARK: - Default Recipes (from CocktailCore)
    func loadDefaultRecipes() {
        defaultRecipes = RecipeLoader.loadDefaultRecipes()
        print(" Loaded \(defaultRecipes.count) default recipes.")
    }
}



//
//import Foundation
//import CocktailCore
//
//@MainActor
//final class RecipeStore: ObservableObject {
//    // MARK: - Published data
//    @Published var defaultRecipes: [Recipe] = []   // Read-only, from CocktailCore package
//    @Published var userRecipes: [Recipe] = []      // Read/write, stored in Documents folder
//    @Published var favoriteRecipes: [Recipe] = []  // Stored favorites
//
//    // MARK: - Init
//    init() {
//        loadDefaultRecipes()
//        loadUserRecipes()
//        loadFavoriteRecipes()
//
//        //  Debug info
//        if let url = getUserRecipesURL() {
//            //print(" User recipe file:", url)
//        }
//        if let favURL = getFavoritesURL() {
//            //print(" Favorites file:", favURL)
//        }
//        print(" Default recipes:", defaultRecipes.count)
//        print(" User recipes:", userRecipes.count)
//        print(" Favorite recipes:", favoriteRecipes.count)
//    }
//
//    // MARK: - Favorite management
//    func toggleFavorite(_ recipe: Recipe) {
//        if let index = favoriteRecipes.firstIndex(where: { $0.id == recipe.id }) {
//            favoriteRecipes.remove(at: index)
//        } else {
//            favoriteRecipes.append(recipe)
//        }
//        saveFavoriteRecipes()
//    }
//
//    func isFavorite(_ recipe: Recipe) -> Bool {
//        favoriteRecipes.contains(where: { $0.id == recipe.id })
//    }
//
//    // MARK: - Load & Save Favorites
//    func loadFavoriteRecipes() {
//        guard let url = getFavoritesURL() else { return }
//        do {
//            let data = try Data(contentsOf: url)
//            favoriteRecipes = try JSONDecoder().decode([Recipe].self, from: data)
//            //print(" Loaded \(favoriteRecipes.count) favorite recipes.")
//        } catch {
//            print(" No favorites found or failed to decode:", error)
//            favoriteRecipes = []
//        }
//    }
//
//    func saveFavoriteRecipes() {
//        guard let url = getFavoritesURL() else { return }
//        do {
//            let data = try JSONEncoder().encode(favoriteRecipes)
//            try data.write(to: url, options: .atomic)
//            print(" Saved \(favoriteRecipes.count) favorite recipes → \(url.lastPathComponent)")
//        } catch {
//            print(" Failed to save favorites:", error)
//        }
//    }
//
//    // MARK: - Default Recipes
//    func loadDefaultRecipes() {
//        defaultRecipes = RecipeLoader.loadDefaultRecipes()
//        //print(" Loaded \(defaultRecipes.count) default recipes from CocktailCore package")
//    }
//
//    // MARK: - User Recipes
//    func loadUserRecipes() {
//        guard let url = getUserRecipesURL() else { return }
//        do {
//            let data = try Data(contentsOf: url)
//            let decoded = try JSONDecoder().decode([Recipe].self, from: data)
//            userRecipes = decoded
//            //print(" Loaded \(userRecipes.count) user recipes from file.")
//        } catch {
//            print(" No user recipes found or failed to decode:", error)
//            userRecipes = []
//        }
//    }
//
//    func addUserRecipe(_ recipe: Recipe) {
//        userRecipes.append(recipe)
//        saveUserRecipes()
//    }
//
//    func saveUserRecipes() {
//        guard let url = getUserRecipesURL() else { return }
//        do {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//            let data = try encoder.encode(userRecipes)
//            try data.write(to: url, options: .atomic)
//            print(" Saved \(userRecipes.count) user recipes → \(url.lastPathComponent)")
//        } catch {
//            print(" Failed to save user recipes:", error)
//        }
//    }
//
//    func deleteUserRecipe(at offsets: IndexSet) {
//        userRecipes.remove(atOffsets: offsets)
//        saveUserRecipes()
//        print(" Deleted recipe at index:", offsets)
//        print(" Remaining user recipes:", userRecipes.count)
//    }
//
//    // MARK: - Helper URLs
//    private func getUserRecipesURL() -> URL? {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//            .first?
//            .appendingPathComponent("user_recipes.json")
//    }
//
//    private func getFavoritesURL() -> URL? {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//            .first?
//            .appendingPathComponent("favorite_recipes.json")
//    }
//}
//
