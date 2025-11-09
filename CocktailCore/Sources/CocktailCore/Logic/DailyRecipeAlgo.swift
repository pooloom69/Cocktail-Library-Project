//
//  DailyRecipeAlgo.swift
//  CocktailCore
//
//  Created by Sola Lhim on 11/3/25.
//

import Foundation


// MARK: - Pure random pick, stable for the day

public final class RandomRecipeOfTheDay {
    private let storedIDKey = "rotd.random.recipeID"
    private let storedDateKey = "rotd.random.date"
    private let calendar: Calendar = {
        var cal = Calendar.current
        return cal
    }()

    public init() {}

    /// Returns today's recipe. Picks a new random one only when the calendar day changes.
    public func today(from all: [Recipe]) -> Recipe? {
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
