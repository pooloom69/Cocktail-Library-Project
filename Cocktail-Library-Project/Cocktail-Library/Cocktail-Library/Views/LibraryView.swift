//
//  LibraryView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 2025-10-20.
//

import SwiftUI
import CocktailCore

struct LibraryView: View {
    @EnvironmentObject var store: RecipeStore
    @State private var searchText = ""
    @State private var selectedTab = "All"
    private let tabs = ["All", "MyRecipe", "Favorite", "Popular"]

    // MARK: - Filtered recipes based on search text
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return store.defaultRecipes
        } else {
            return store.defaultRecipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Title
                Text("Cocktail Library")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Search bar
                LibrarySearchBar(text: $searchText)

                // Tabs
                Picker("Tabs", selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: - Tab Contents
                Group {
                    switch selectedTab {
                    case "All":
                        AllRecipesView(recipes: filteredRecipes)

                    case "MyRecipe":
                        MyRecipesView(store: store)

                    case "Favorite":
                        Text("Favorite Recipes (coming soon)")
                            .foregroundColor(.gray)
                            .padding(.top, 50)

                    case "Popular":
                        Text("Popular Recipes (coming soon)")
                            .foregroundColor(.gray)
                            .padding(.top, 50)

                    default:
                        EmptyView()
                    }
                }
                .padding(.top)
            }
            .padding(.horizontal)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LibraryView().environmentObject(RecipeStore())
}

// MARK: - All Recipes Tab
struct AllRecipesView: View {
    let recipes: [Recipe]

    var body: some View {
        if recipes.isEmpty {
            VStack {
                ProgressView()
                Text("Loading recipes...")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        } else {
            List(recipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(recipe.name)
                            .font(.headline)
                        Text(recipe.base)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - My Recipes Tab
struct MyRecipesView: View {
    @ObservedObject var store: RecipeStore

    var body: some View {
        if store.userRecipes.isEmpty {
            VStack(spacing: 10) {
                Text("No user recipes yet.")
                    .foregroundColor(.gray)

                NavigationLink {
                    CreateNew()
                } label: {
                    Label("Create New Recipe", systemImage: "plus.circle.fill")
                }
                .padding(.top, 8)
            }
        } else {
            List {
                ForEach(store.userRecipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text(recipe.style)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: store.deleteUserRecipe)
            }
            .listStyle(.insetGrouped)

            NavigationLink {
                CreateNew()
            } label: {
                Label("Create New Recipe", systemImage: "plus.circle.fill")
            }
            .padding(.top)
        }
    }
}

// MARK: - Search Bar component
struct LibrarySearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
