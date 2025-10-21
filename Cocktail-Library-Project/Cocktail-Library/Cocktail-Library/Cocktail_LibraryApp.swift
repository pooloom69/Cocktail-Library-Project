//
//  Cocktail_LibraryApp.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 9/10/25.
//

import SwiftUI
import CocktailCore

@main
struct Cocktail_LibraryApp: App {
    @StateObject private var store = RecipeStore()
    

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store) 
        }
    }
}
