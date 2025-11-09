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
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss

    let units = ["oz", "ml", "dash", "slice", "bar spoon"]
    let ingredientsList = ["Lime", "Sugar", "Mint", "Soda", "Triple Sec", "Bitters"]

    let bases: [String] = VectorOrders.baseOrder
        .filter { $0 != "vermouth_fortified" }
        .map { $0.replacingOccurrences(of: "_", with: " ") }
        .map { $0.capitalized }

    let styles: [String] = VectorOrders.styleOrder
        .map { $0.replacingOccurrences(of: "_", with: " ") }
        .map { $0.capitalized }

    let flavors: [String] = VectorOrders.flavorOrder
        .map { $0.replacingOccurrences(of: "_", with: " ") }
        .map { $0.capitalized }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // MARK: - Header
                    HStack {
                        Text("Create Your Own Recipe")
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
                    .padding(.top, 8)

                    Divider().background(AppTheme.divider)

                    // MARK: - Recipe Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recipe Name")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        TextField("Enter recipe name", text: $recipeName)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    // MARK: - Base Spirit
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Base Spirit")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Picker("Select Base", selection: $selectedBase) {
                            ForEach(bases, id: \.self) { base in
                                Text(base).tag(base)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppTheme.highlight)
                    }

                    // MARK: - Style
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Style")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Picker("Select Style", selection: $selectedStyle) {
                            ForEach(styles, id: \.self) { style in
                                Text(style).tag(style)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppTheme.highlight)
                    }

                    // MARK: - Flavor Chips
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Flavors")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(flavors, id: \.self) { flavor in
                                    let isSelected = selectedFlavors.contains(flavor)
                                    Text(flavor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? AppTheme.chipSelected : AppTheme.card)
                                        .foregroundColor(AppTheme.textPrimary)
                                        .cornerRadius(10)
                                        .shadow(color: AppTheme.softShadow, radius: isSelected ? 3 : 0, y: 1)
                                        .onTapGesture {
                                            if isSelected {
                                                selectedFlavors.remove(flavor)
                                            } else {
                                                selectedFlavors.insert(flavor)
                                            }
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
                            .foregroundColor(AppTheme.textPrimary)

                        ForEach($recipeIngredients) { $ingredient in
                            HStack {
                                TextField("Ingredient", text: $ingredient.name)
                                    .textFieldStyle(CustomTextFieldStyle())

                                Menu {
                                    ForEach(ingredientsList, id: \.self) { ing in
                                        Button(ing) { ingredient.name = ing }
                                    }
                                } label: {
                                    Image(systemName: "chevron.down.circle")
                                        .foregroundColor(AppTheme.highlight)
                                }

                                TextField("Amt", value: $ingredient.amount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 55)
                                    .textFieldStyle(CustomTextFieldStyle())

                                Picker("Unit", selection: $ingredient.unit) {
                                    ForEach(units, id: \.self) { unit in
                                        Text(unit).tag(unit)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 70)

                                Button {
                                    if let index = recipeIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                        recipeIngredients.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }

                        Button {
                            recipeIngredients.append(Ingredient(name: "", amount: 0.0, unit: "oz"))
                        } label: {
                            Label("Add Ingredient", systemImage: "plus.circle.fill")
                                .foregroundColor(AppTheme.highlight)
                        }
                        .padding(.top, 4)
                    }

                    // MARK: - Steps
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        TextEditor(text: $instructions)
                            .frame(height: 120)
                            .scrollContentBackground(.hidden)
                            .background(AppTheme.card)
                            .cornerRadius(8)
                            .shadow(color: AppTheme.softShadow, radius: 2, y: 1)
                    }

                    // MARK: - Save Button
                    Button {
                        saveNewRecipe()
                    } label: {
                        Text("Save Recipe")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.highlight)
                            .cornerRadius(12)
                            .shadow(color: AppTheme.softShadow, radius: 3, y: 2)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
            }
            .background(AppTheme.background.ignoresSafeArea())
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

// MARK: - Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(AppTheme.card)
            .cornerRadius(8)
            .shadow(color: AppTheme.softShadow, radius: 1, y: 1)
            .foregroundColor(AppTheme.textPrimary)
    }
}


// MARK: - Preview
#Preview {
    CreateNew()
        .environmentObject(RecipeStore())
        .environmentObject(UserSession())
}
