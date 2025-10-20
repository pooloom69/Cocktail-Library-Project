// Recipe.swift

import Foundation

public struct Recipe: Codable, Identifiable, Hashable {
    public var id: String
    public var name: String
    public var base: String
    public var style: String
    public var flavor: [String]
    public var abv: Double
    public var ice: String
    public var ingredients: [Ingredient]
    public var steps: [String]
    public var glass: String
    public var garnish: [String]


    public init(
        id: String = UUID().uuidString,
        name: String,
        base: String,
        style: String,
        flavor: [String],
        abv: Double,
        ice: String,
        ingredients: [Ingredient],
        steps: [String],
        glass: String,
        garnish: [String]
    ) {
        self.id = id
        self.name = name
        self.base = base
        self.style = style
        self.flavor = flavor
        self.abv = abv
        self.ice = ice
        self.ingredients = ingredients
        self.steps = steps
        self.glass = glass
        self.garnish = garnish
    }
}
