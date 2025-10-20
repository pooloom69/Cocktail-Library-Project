
import Foundation

public struct RecipeLoader {
    public static func loadDefaultRecipes() -> [Recipe] {
        var loaded: [Recipe] = []

        let bundle = Bundle.module
        if let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            print("Found \(urls.count) JSON files in package:")
            urls.forEach { print(" - \($0.lastPathComponent)") }

            for url in urls {
                do {
                    let data = try Data(contentsOf: url)
                    let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                    //print("Loaded recipe:", recipe.name)
                    loaded.append(recipe)
                } catch {
                    print(" Failed to decode \(url.lastPathComponent):", error)
                }
            }
        } else {
            print(" No JSON files found in bundle")
        }

        print(" Total recipes loaded: \(loaded.count)")
        return loaded
    }
}


