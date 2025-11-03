import Foundation

// MARK: - Models (mirror your JSON keys exactly)

struct VectorBlock: Codable, Hashable {
    let scale: String
    let order: [String]
    let vector: [Double]
    let version: Int
}

struct Ingredient: Codable, Hashable {
    let name: String
    let amount: Double
    let unit: String
}

struct Recipe: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let base: String
    let style: String
    let flavor: [String]
    let base_vector: VectorBlock
    let style_vector: VectorBlock
    let flavor_vector: VectorBlock
    let abv: Double
    let ice: String
    let ingredients: [Ingredient]
    let steps: [String]
    let glass: String
    let garnish: [String]
}

// MARK: - Loader (loads *.json from Bundle subfolder "Recipes")

enum RecipeLoader {
    static func loadAllFromBundle() -> [Recipe] {
        var all: [Recipe] = []

        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Recipes") else {
            print("No recipe JSON files found in Bundle /Recipes")
            return []
        }

        let decoder = JSONDecoder()
        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                // Support either a single recipe JSON or an array-of-recipes file
                if let one = try? decoder.decode(Recipe.self, from: data) {
                    all.append(one)
                } else if let many = try? decoder.decode([Recipe].self, from: data) {
                    all.append(contentsOf: many)
                } else {
                    print("Unrecognized JSON format at \(url.lastPathComponent)")
                }
            } catch {
                print("Failed to decode \(url.lastPathComponent): \(error)")
            }
        }
        return all
    }
}

// MARK: - Pure random pick, stable for the day

final class RandomRecipeOfTheDay {
    private let storedIDKey = "rotd.random.recipeID"
    private let storedDateKey = "rotd.random.date"
    private let calendar: Calendar = {
        var cal = Calendar.current
        // If you want a fixed timezone, set it here (e.g., TimeZone(identifier: "America/Los_Angeles"))
        return cal
    }()

    /// Returns today's recipe. Picks a new random one only when the calendar day changes.
    func today(from all: [Recipe]) -> Recipe? {
        guard !all.isEmpty else { return nil }

        let defaults = UserDefaults.standard
        let todayStart = calendar.startOfDay(for: Date())

        if let savedID = defaults.string(forKey: storedIDKey),
           let savedDate = defaults.object(forKey: storedDateKey) as? Date,
           calendar.isDate(savedDate, inSameDayAs: todayStart),
           let match = all.first(where: { $0.id == savedID }) {
            return match
        }

        // Pick fresh random and store
        let pick = all.randomElement()!
        defaults.set(pick.id, forKey: storedIDKey)
        defaults.set(todayStart, forKey: storedDateKey)
        return pick
    }
}

/* Example usage

// In your app start / view model:
let allRecipes = RecipeLoader.loadAllFromBundle()
let rotd = RandomRecipeOfTheDay()

if let today = rotd.today(from: allRecipes) {
    print("Recipe of the Day: \(today.name) (\(today.base))")
} else {
    print("No recipes loaded.")
} 

*/

