import Foundation

public struct Ingredient: Codable, Hashable, Identifiable {
    public var id: UUID = UUID()
    public var name: String
    public var amount: Double
    public var unit: String

    // Custom decoding initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.unit = try container.decode(String.self, forKey: .unit)
        // If JSON doesn't have "id", assign a random one
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
    }

    public init(id: UUID = UUID(), name: String, amount: Double, unit: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, amount, unit
    }
}
