//
//  CreateNew.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 9/10/25.
//

import SwiftUI
import CocktailCore

struct CreateNew: View {
    @State private var recipeName = ""
    @State private var selectedBase = "Gin"
    @State private var selectedStyle = "Classic"
    @State private var selectedFlavors: Set<String> = []
    @State private var instructions = ""
    @State private var recipeIngredients: [Ingredient] = [
        Ingredient(name: "", amount: 0.0, unit: "oz")
    ]

    @EnvironmentObject var store: RecipeStore
    @Environment(\.dismiss) var dismiss

    // MARK: - Constants
    let units = ["oz", "ml", "dash", "slice", "bar spoon"]
    let ingredientsList = ["Lime", "Sugar", "Mint", "Soda", "Triple Sec", "Bitters"]
    let bases = ["Gin", "Vodka", "Rum", "Whiskey", "Tequila", "Brandy", "Mezcal", "Sake", "Soju"]
    let styles = ["Classic", "Spritz", "Highball", "Martini", "Old Fashioned", "Tiki"]
    let flavors = ["Sweet", "Bitter", "Sour", "Fruity", "Spicy"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Title
                    Text("Create Your Own Recipe")
                        .font(.title)
                        .bold()
                        .padding(.top)

                    // MARK: - Recipe Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recipe Name")
                            .font(.headline)
                            .padding(.top)
                        TextField("Enter recipe name", text: $recipeName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // MARK: - Base Spirit
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Base Spirit")
                            .font(.headline)
                        Picker("Select Base", selection: $selectedBase) {
                            ForEach(bases, id: \.self) { base in
                                Text(base).tag(base)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // MARK: - Style
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Style")
                            .font(.headline)
                        Picker("Select Style", selection: $selectedStyle) {
                            ForEach(styles, id: \.self) { style in
                                Text(style).tag(style)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // MARK: - Flavor Tags
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Flavors")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(flavors, id: \.self) { flavor in
                                    Button {
                                        if selectedFlavors.contains(flavor) {
                                            selectedFlavors.remove(flavor)
                                        } else {
                                            selectedFlavors.insert(flavor)
                                        }
                                    } label: {
                                        Text(flavor)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedFlavors.contains(flavor)
                                                        ? Color.orange
                                                        : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedFlavors.contains(flavor) ? .white : .black)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }

                    // MARK: - Ingredients Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.headline)

                        ForEach($recipeIngredients) { $ingredient in
                            HStack {
                                // Ingredient name
                                TextField("Ingredient", text: $ingredient.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                // Quick pick menu
                                Menu {
                                    ForEach(ingredientsList, id: \.self) { ing in
                                        Button(ing) { ingredient.name = ing }
                                    }
                                } label: {
                                    Image(systemName: "chevron.down.circle")
                                        .foregroundColor(.blue)
                                }

                                // Amount
                                TextField("Amt", value: $ingredient.amount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 55)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                // Unit
                                Picker("Unit", selection: $ingredient.unit) {
                                    ForEach(units, id: \.self) { unit in
                                        Text(unit).tag(unit)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 70)

                                // Delete button
                                Button {
                                    if let index = recipeIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                        recipeIngredients.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                        // Add new ingredient row
                        Button {
                            recipeIngredients.append(Ingredient(name: "", amount: 0.0, unit: "oz"))
                        } label: {
                            Label("Add Ingredient", systemImage: "plus.circle.fill")
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    }

                    // MARK: - Steps
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Steps")
                            .font(.headline)
                        TextEditor(text: $instructions)
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // MARK: - Save Button
                    Button {
                        saveNewRecipe()
                    } label: {
                        Text("Save Recipe")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Save Logic
    private func saveNewRecipe() {
        let newRecipe = Recipe(
            id: UUID().uuidString,
            name: recipeName,
            base: selectedBase,
            style: selectedStyle,
            flavor: Array(selectedFlavors),
            abv: 0.0,
            ice: "",
            ingredients: recipeIngredients,
            steps: instructions.split(separator: "\n").map(String.init),
            glass: "",
            garnish: []
        )

        store.addUserRecipe(newRecipe)
        print(" Recipe Saved:", newRecipe.name)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    CreateNew()
        .environmentObject(RecipeStore())
}
