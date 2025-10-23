//
//  RecommendationView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 2025-10-21.
//

import SwiftUI
import CocktailCore

/// Displays the list of recommended cocktail recipes based on the similarity ranking.
struct RecommendationView: View {
    /// Ranked results returned from the Recommender algorithm
    let results: [RankResult]
    /// The complete list of available recipes (for lookup)
    let allRecipes: [Recipe]

    @EnvironmentObject var store: RecipeStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header title
                Text("Recommended Recipes")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // If no matches found
                if results.isEmpty {
                    VStack(spacing: 10) {
                        Text("No matching recipes found.")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Try adjusting your filters or keyword search.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else {
                    // Render each ranked result as a card
                    ForEach(results, id: \.id) { result in
                        if let recipe = allRecipes.first(where: { $0.id == result.id }) {
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecommendationCard(recipe: recipe, result: result)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Recommendations")
    }
}

/// A visual card displaying recipe summary and similarity score.
struct RecommendationCard: View {
    let recipe: Recipe
    let result: RankResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Placeholder image section
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.15))
                    .frame(height: 180)
                    .overlay(
                        // Displays the first letter of the cocktail name if no image available
                        Text(recipe.name.prefix(1))
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.white.opacity(0.3))
                    )
            }

            // Recipe info and similarity details
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)

                Text("\(recipe.base) • \(recipe.style)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Display similarity breakdown
                HStack(spacing: 8) {
                    Text("Score: \(result.score, specifier: "%.2f")")
                    Text("Flavor: \(result.explain.flavorSim, specifier: "%.2f")")
                    Text("Style: \(result.explain.styleSim, specifier: "%.2f")")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.bottom, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}



struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        // Simple placeholder VectorBlock
        let sampleVector = VectorBlock(
            scale: "default",
            order: ["Sweet", "Bitter"],
            vector: [0.8, 0.2],
            version: 1
        )
        
        // Mock recipe
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
        
        // Mock rank result
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
        
        // Preview with mock data
        RecommendationView(
            results: [sampleResult],
            allRecipes: [sampleRecipe]
        )
        .environmentObject(RecipeStore())
    }
}
