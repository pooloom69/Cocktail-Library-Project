//
//  RecipeLoader.swift
//  CocktailCore
//
//  Created by Sola Lhim.
//

import Foundation

public struct RecipeLoader {

    public static func loadDefaultRecipes() -> [Recipe] {
        var loaded: [Recipe] = []

//        print("📦 Bundle.module.bundlePath =", Bundle.module.bundlePath)
//        print("📦 Bundle.module.resourcePath =", Bundle.module.resourcePath ?? "nil")


        if let resourcePath = Bundle.module.resourcePath {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                //print("📁 Bundle contents:", contents)
            } catch {
                print("⚠️ Failed to list bundle contents:", error)
            }
        }

        if let urls = Bundle.module.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            //print("📦 Found \(urls.count) JSON files in package:")
            urls.forEach { print(" - \($0.lastPathComponent)") }

            for url in urls {
                do {
                    let data = try Data(contentsOf: url)
                    let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                    loaded.append(recipe)
                   // print(" Loaded recipe:", recipe.name)
                } catch {
                    print(" Failed to decode \(url.lastPathComponent):", error)
                }
            }
        } else {
            print("❌ No JSON files found in Bundle.module/Data")
        }

        print("➡️ Total recipes loaded:", loaded.count)
        return loaded
    }
}
