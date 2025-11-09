//
//  RecipeDetailView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 10/20/25.
//

import SwiftUI
import CocktailCore

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var store: RecipeStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("\(recipe.base) • \(recipe.style)")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                    Button {
                        store.toggleFavorite(recipe)
                    } label: {
                        Image(systemName: store.isFavorite(recipe) ? "heart.fill" : "heart")
                            .foregroundColor(store.isFavorite(recipe) ? AppTheme.highlight : AppTheme.textSecondary)
                            .font(.title2)
                            .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // MARK: - Flavor Tags
                if !recipe.flavor.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Flavors")
                            .font(.headline)
                            .foregroundColor(AppTheme.highlight)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(recipe.flavor, id: \.self) { flavor in
                                    Text(flavor.capitalized)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.card)
                                        .cornerRadius(10)
                                        .shadow(color: AppTheme.softShadow, radius: 1, y: 1)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(AppTheme.highlight.opacity(0.3), lineWidth: 1)
                                        )
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: - Ingredients
                if !recipe.ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .font(.headline)
                            .foregroundColor(AppTheme.highlight)
                        ForEach(recipe.ingredients, id: \.id) { ing in
                            HStack {
                                Text("•")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("\(ing.amount, specifier: "%.1f") \(ing.unit) \(ing.name)")
                                    .font(AppTheme.bodyFont())
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: - Steps
                if !recipe.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(AppTheme.highlight)
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(step)
                                    .font(AppTheme.bodyFont())
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: - Garnish
                if !recipe.garnish.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Garnish")
                            .font(.headline)
                            .foregroundColor(AppTheme.highlight)
                        Text(recipe.garnish.joined(separator: ", "))
                            .font(AppTheme.bodyFont())
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .padding(.horizontal)
                }

                // MARK: - Glass & Ice Info (optional)
                if !recipe.glass.isEmpty || !recipe.ice.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        if !recipe.glass.isEmpty {
                            Text("Glass: \(recipe.glass)")
                                .font(AppTheme.bodyFont())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        if !recipe.ice.isEmpty {
                            Text("Ice: \(recipe.ice)")
                                .font(AppTheme.bodyFont())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 60)
            }
            .padding(.bottom, 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        RecipeDetailView(
            recipe: Recipe(
                id: UUID().uuidString,
                name: "Sample Negroni",
                base: "Gin",
                style: "Classic",
                flavor: ["bitter", "sweet"],
                abv: 0.25,
                ice: "Build over ice",
                ingredients: [
                    Ingredient(name: "Gin", amount: 1.0, unit: "oz"),
                    Ingredient(name: "Campari", amount: 1.0, unit: "oz"),
                    Ingredient(name: "Sweet Vermouth", amount: 1.0, unit: "oz")
                ],
                steps: [
                    "Stir all ingredients with ice until well chilled.",
                    "Strain into a rocks glass.",
                    "Garnish with an orange peel."
                ],
                glass: "Rocks glass",
                garnish: ["Orange peel"]
            )
        )
        .environmentObject(RecipeStore())
    }
}
