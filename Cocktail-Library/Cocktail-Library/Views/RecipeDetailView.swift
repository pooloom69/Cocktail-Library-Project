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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()
                
                HStack {
                    Text("Base: \(recipe.base)")
                    Spacer()
                    Text("Style: \(recipe.style)")
                }
                .font(.headline)
                
                // Flavor tags
                if !recipe.flavor.isEmpty {
                    Text("Flavors")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recipe.flavor, id: \.self) { flavor in
                                Text(flavor.capitalized)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    // Ingredients
                    if !recipe.ingredients.isEmpty {
                        Text("Ingredients")
                            .font(.headline)
                        ForEach(recipe.ingredients, id: \.id) { ing in
                            Text("• \(ing.amount, specifier: "%.1f") \(ing.unit) \(ing.name)")
                        }
                    }
                    
                    // Steps
                    if !recipe.steps.isEmpty {
                        Text("Steps")
                            .font(.headline)
                        ForEach(recipe.steps, id: \.self) { step in
                            Text(step)
                                .padding(.vertical, 2)
                        }
                    }
                    
                    if !recipe.garnish.isEmpty {
                        Text("Garnish")
                            .font(.headline)
                        Text(recipe.garnish.joined(separator: ", "))
                    }
                    
                    Spacer()
                }
                
            }
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
    }
    
    struct RecipeDetailView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                RecipeDetailView(recipe: Recipe(
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
                    steps: ["Stir all ingredients with ice", "Strain into glass"],
                    glass: "Rocks glass",
                    garnish: ["Orange peel"]
                ))
            }
        }
    }
}
//struct RecipeDetailView: View {
//    let recipe: Recipe   
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//             
//                Text(recipe.name)
//                    .font(.largeTitle)
//                    .bold()
//                    .padding(.top)
//
//    
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Base: \(recipe.base)")
//                    Text("Style: \(recipe.style)")
//                    Text(String(format: "ABV: %.1f%%", recipe.abv * 100))
//                    Text("Glass: \(recipe.glass)")
//                    Text("Ice: \(recipe.ice)")
//                }
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//                Divider().padding(.vertical, 8)
//
//
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Ingredients")
//                        .font(.headline)
//                    ForEach(recipe.ingredients, id: \.name) { ingredient in
//                        Text("• \(ingredient.amount, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
//                    }
//                }
//
//                Divider().padding(.vertical, 8)
//
//  
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Steps")
//                        .font(.headline)
//                    ForEach(recipe.steps, id: \.self) { step in
//                        Text("• \(step)")
//                    }
//                }
//
//                Divider().padding(.vertical, 8)
//
//
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Garnish")
//                        .font(.headline)
//                    ForEach(recipe.garnish, id: \.self) { item in
//                        Text("• \(item)")
//                    }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle(recipe.name)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
