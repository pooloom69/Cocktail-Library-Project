//
//  RecommendationView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 2025-10-21.
//

import SwiftUI
import CocktailCore

struct RecommendationView: View {
    let results: [RankResult]
    let allRecipes: [Recipe]
    @EnvironmentObject var store: RecipeStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header
                Text("Recommended Recipes")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 16)
                    .padding(.horizontal)

                // MARK: - Empty State
                if results.isEmpty {
                    VStack(spacing: 10) {
                        Text("No matching recipes found.")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary.opacity(0.6))
                        Text("Try adjusting your filters or keywords.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.card)
                            .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
                    )
                    .padding(.horizontal)
                } else {
                    // MARK: - Recommendation Cards
                    VStack(spacing: 16) {
                        ForEach(results, id: \.id) { result in
                            if let recipe = allRecipes.first(where: { $0.id == result.id }) {
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecommendationCard(recipe: recipe, result: result)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Recommendations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Recommendation Card
struct RecommendationCard: View {
    let recipe: Recipe
    let result: RankResult

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // MARK: - Image or Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.highlight.opacity(0.3),
                                AppTheme.card.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                    .shadow(color: AppTheme.softShadow, radius: 3, y: 2)
                    .overlay(
                        Text(recipe.name.prefix(1))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary.opacity(0.1))
                    )
            }

            // MARK: - Text Info
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)

                Text("\(recipe.base) • \(recipe.style)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)

                // Similarity score
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppTheme.highlight)
                    Text("Match Score: \(result.score, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.card)
                .shadow(color: AppTheme.softShadow, radius: 3, y: 2)
        )
    }
}

#Preview {
    let sampleVector = VectorBlock(
        scale: "default",
        order: ["Sweet", "Bitter"],
        vector: [0.8, 0.2],
        version: 1
    )

    let sampleRecipe = Recipe(
        id: "1",
        name: "Mocktail Sunrise",
        base: "Vodka",
        style: "Highball",
        flavor: ["Sweet", "Fruity"],
        abv: 0.15,
        ice: "Cubed",
        ingredients: [],
        steps: ["Shake all ingredients", "Pour over ice"],
        glass: "Highball",
        garnish: ["Orange Slice"],
        base_vector: sampleVector,
        style_vector: sampleVector,
        flavor_vector: sampleVector
    )

    let sampleResult = RankResult(
        id: "1",
        name: "Mocktail Sunrise",
        score: 0.95,
        explain: RankResult.Explain(
            flavorSim: 0.9,
            styleSim: 0.8,
            baseSim: 0.85,
            kwBoost: 0.1
        )
    )

    return NavigationView {
        RecommendationView(results: [sampleResult], allRecipes: [sampleRecipe])
            .environmentObject(RecipeStore())
    }
}

