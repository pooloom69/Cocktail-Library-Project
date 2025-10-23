import Foundation

// MARK: - Vector Representation
public struct VectorBlock: Codable, Hashable {
    public let scale: String?
    public let order: [String]
    public let vector: [Double]
    public let version: Int?
    
    public init(
        scale: String? = nil,
        order: [String] = [],
        vector: [Double] = [],
        version: Int? = nil
    ) {
        self.scale = scale
        self.order = order
        self.vector = vector
        self.version = version
    }
}



// MARK: - Recipe
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

    public var base_vector: VectorBlock?
    public var style_vector: VectorBlock?
    public var flavor_vector: VectorBlock?

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
        garnish: [String],
        base_vector: VectorBlock? = nil,
        style_vector: VectorBlock? = nil,
        flavor_vector: VectorBlock? = nil
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
        self.base_vector = base_vector
        self.style_vector = style_vector
        self.flavor_vector = flavor_vector
    }
}
