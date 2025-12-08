###🍸 Cocktail Library

A personalized cocktail recipe app built with SwiftUI and powered by a modular logic engine.

📱 Overview

Cocktail Library is an iOS application designed to provide a clean, intuitive, and highly personalized way to browse, create, and explore cocktail recipes.
The project emphasizes:

Elegant, modern UI/UX

Clear recipe browsing & searching

A user-friendly system for creating and saving personalized recipes

A recommendation engine using vector similarity

Popular cocktail rankings sourced from web data

The app is structured using a dedicated Swift Package (CocktailCore) that contains all cocktail data, vector logic, popularity rankings, and embedded image resources.

🌿 Features
🔍 Search & Browse Recipes

Keyword-based search

Cocktail library with detailed recipe views

Base, style, and flavor information displayed clearly

⭐ Personal Account & Saved Data

Using Firebase Authentication:

Sign up / Sign in

Save "My Recipes"

Save Favorites

Persistent user storage

✏️ Create Your Own Recipe

Users can:

Enter recipe name & details

Select base spirit, style, and flavor tags

Add/remove ingredients dynamically

Write detailed step instructions

Save the recipe into their personal library

🧠 Recommendation Engine

Powered by CocktailCore:

Vector similarity using cosine similarity

Understands base, style, flavor relationships

Displays the Top 10 recommended cocktails based on user inputs

Clear recommendation cards for user exploration

🔥 Popular Cocktail Rankings

Python script scrapes Difford’s Guide Top 100

Matches scraped names to local recipe IDs

Generates cocktail_popularity.json inside the SPM

Popular tab displays cocktails ranked by popularity + external ranking

🖼️ Recipe Image Integration

Cocktail images stored inside CocktailCore/Data/Cocktail-Images

Smart name-matching system finds the correct image based on recipe ID or name

Uses fallback strategies (_classic, _original, base keys, etc.)

Recipe detail view displays a large header image with safe scaling

🎨 UI & Theme

The visual theme reflects:

Dusty Rose

Cream Beige

Brown Ink accents

Muted Purple highlight

Design philosophy:

Soft & warm

Minimal shadows

Rounded corners

High readability

Calm background gradients

Screens include:

Library View

Recommendation View

Create New Recipe

Profile / Login

Recipe Detail View with image header

🧩 Architecture
App Layer (Cocktail-Library App)

SwiftUI Views

State management using ObservableObject (RecipeStore, UserSession)

Navigation & UI logic

Firebase integration

Logic Layer (CocktailCore Package)

Contains:
```text
CocktailCore/
├── Models/
├── Data/
│   ├── Recipes JSON
│   ├── Cocktail Images
│   └── cocktail_popularity.json
├── PopularityLoader
├── ImageLoader
├── Vector similarity logic
└── Recipe ordering data (VectorOrders)
```
The package is reusable and cleanly separated from UI logic.

🔧 Tech Stack
Frontend

SwiftUI

MVVM-like component structure

Custom UI components (SearchBar, Chips, Cards, etc.)

Backend / Services

Firebase Authentication

Firestore + local logic for user data

Data & Scripts

Python (Requests + BeautifulSoup)

Automated matching + JSON generation

SPM resource bundles

🗂 Folder Structure
```text
Cocktail-Library/
 ├── Views/
 ├── Components/
 ├── Theme/
 ├── Models/
 ├── Stores/
 └── Assets/

CocktailCore/
 ├── Models/
 ├── Data/
 │    ├── Recipes/
 │    ├── Cocktail-Images/
 │    └── cocktail_popularity.json
 ├── PopularityLoader.swift
 ├── ImageLoader.swift
 └── Vector logic
```
🚀 Running the App
1. Clone the repository
git clone https://github.com/solalhim/Cocktail-Library.git

2. Install Dependencies

Xcode automatically resolves Swift Package dependencies.

3. Run on Simulator or Device

You need:

Xcode 15+

iOS 17 device or simulator

On device:
Enable developer mode → Trust your Mac → Build & run.

🧪 Testing

Test individual logic functions under CocktailCoreTests

Unit tests for popularity loading, vector comparison, data decoding

📌 Future Improvements

Public recipe sharing between users

Community recipe rating

Cocktail tasting notes

AI ingredient substitution suggestions

Seasonal collections

Push notifications for weekly trending cocktails

🥂 License

MIT License — free to use, modify, and distribute.




