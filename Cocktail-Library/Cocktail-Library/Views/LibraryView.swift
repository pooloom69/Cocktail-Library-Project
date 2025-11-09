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
    @EnvironmentObject var userSession: UserSession
    
    @State private var searchText = ""
    @State private var selectedTab = "All"
    private let tabs = ["All", "MyRecipe", "Favorite", "Popular"]
    
    // MARK: - Filter recipes based on search
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
            VStack(spacing: 0) {
                
                // MARK: - Fixed Header
                VStack(spacing: 14) {
                    // Header Title + User Info
                    HStack {
                        Text("Cocktail Library")
                            .font(AppTheme.titleFont())
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        if userSession.currentUser != nil {
                            HStack(spacing: 6) {
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(userSession.username.isEmpty ? "..." : userSession.username)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    
                    // Search Bar
                    LibrarySearchBar(text: $searchText)
                        .background(AppTheme.card)
                        .cornerRadius(12)
                        .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
                    
                    // Segmented Tabs
                    Picker("Tabs", selection: $selectedTab) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab)
                                .tag(tab)
                                .font(.body)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(AppTheme.highlight)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 10)
                .background(AppTheme.background)
                .shadow(color: AppTheme.softShadow.opacity(0.3), radius: 3, y: 1)
                
                // MARK: - Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 14, pinnedViews: []) {
                        switch selectedTab {
                        case "All":
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(recipe.name)
                                            .font(.headline)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text(recipe.base)
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppTheme.card)
                                    .cornerRadius(12)
                                    .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
                                }
                                .buttonStyle(.plain)
                            }
                            
                        case "MyRecipe":
                            MyRecipesListView(store: store)
                            
                        case "Favorite":
                            FavoriteRecipesListView(store: store)
                            
                        case "Popular":
                            Text("Popular Recipes (coming soon)")
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.top, 50)
                            
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
                .background(AppTheme.background)
            }
            .navigationBarHidden(true)
            .background(AppTheme.background.ignoresSafeArea())
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(RecipeStore())
        .environmentObject(UserSession())
}

// MARK: - My Recipes
struct MyRecipesListView: View {
    @ObservedObject var store: RecipeStore
    
    var body: some View {
        if store.userRecipes.isEmpty {
            VStack(spacing: 10) {
                Text("No user recipes yet.")
                    .foregroundColor(AppTheme.textSecondary)
                
                NavigationLink {
                    CreateNew()
                } label: {
                    Label("Create New Recipe", systemImage: "plus.circle.fill")
                        .font(AppTheme.bodyFont())
                        .foregroundColor(AppTheme.highlight)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, minHeight: 200)
        } else {
            ForEach(store.userRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text(recipe.style)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Favorite Recipes
struct FavoriteRecipesListView: View {
    @ObservedObject var store: RecipeStore
    
    var body: some View {
        if store.favoriteRecipes.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.textSecondary)
                Text("No favorite recipes yet.")
                    .font(.headline)
                    .foregroundColor(AppTheme.textSecondary)
                Text("Tap the ❤️ in a recipe to add it here.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary.opacity(0.8))
            }
            .frame(maxWidth: .infinity, minHeight: 200)
        } else {
            ForEach(store.favoriteRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.name)
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(recipe.base)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "heart.fill")
                            .foregroundColor(AppTheme.highlight)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Search Bar
struct LibrarySearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
            TextField("Search...", text: $text)
                .font(AppTheme.bodyFont())
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(10)
        .background(AppTheme.card)
        .cornerRadius(12)
        .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
    }
}
