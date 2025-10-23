//
//  ViewOrders.swift
//  CocktailCore
//
//  Created by Sola Lhim on 10/22/25.
//

import Foundation

public struct VectorOrders {
    
    /// Base spirits and key liquid categories used for base vectors
    public static let baseOrder: [String] = [
        "vodka",
        "gin",
        "rum",
        "tequila",
        "mezcal",
        "whiskey",
        "brandy_cognac",
        "aperitif_liqueur",
        "vermouth_fortified",
        "wine_sparkling",
        "beer_cider",
        "nonalcoholic_modifier"
    ]
    
    /// Canonical cocktail style categories (covering all recipes in your library)
    public static let styleOrder: [String] = [
        "spirit_forward",
        "sour",
        "highball",
        "collins",
        "fizz",
        "smash_julep",
        "tiki_exotic",
        "flip_nogg",
        "hot",
        "dessert_after_dinner",
        "punch_large_format",
        "low_abv_aperitivo",
        "frozen_blended",
        "shot_layered"
    ]
    
    /// Full flavor dimension space for all flavor vectors
    public static let flavorOrder: [String] = [
        "sweet",
        "sour",
        "bitter",
        "salty",
        "umami",
        "boozy",
        "fruity",
        "herbal",
        "spicy",
        "smoky",
        "creamy",
        "effervescent"
    ]
}
