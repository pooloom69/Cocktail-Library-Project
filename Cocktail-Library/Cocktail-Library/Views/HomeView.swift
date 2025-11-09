import SwiftUI
import CocktailCore

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedBases: Set<String> = []
    @State private var selectedStyles: Set<String> = []
    @State private var selectedFlavors: Set<String> = []
    @State private var allRecipes: [Recipe] = []
    @State private var recommendations: [RankResult] = []
    @State private var recipeOfTheDay: Recipe?
    private let rotd = RandomRecipeOfTheDay()

    
    @EnvironmentObject var store: RecipeStore
    @EnvironmentObject var userSession: UserSession
    
    // MARK: - Constants
    let bases: [String] = VectorOrders.baseOrder
        .filter { $0 != "vermouth_fortified" }                 // ignore this item
        .map { $0.replacingOccurrences(of: "_", with: " ") }   // convert underscores to spaces
        .map { $0.capitalized }                                // optional: capitalize words

    let styles: [String] = VectorOrders.styleOrder
        .map { $0.replacingOccurrences(of: "_", with: " ") }
        .map { $0.capitalized }

    let flavors: [String] = VectorOrders.flavorOrder
        .map { $0.replacingOccurrences(of: "_", with: " ") }
        .map { $0.capitalized }
    
    
    var body: some View {
        NavigationStack{
            
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                                Text("Cocktail Library")
                                        .font(AppTheme.titleFont())
                                          .foregroundColor(AppTheme.textPrimary)

                                Spacer() // pushes user info to the right edge

                            if userSession.currentUser != nil {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.crop.circle")
                                        .foregroundColor(.secondary)
                                    Text(userSession.username.isEmpty ? "..." : userSession.username)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }
                        .padding(.top) // add some space from the top edge

                    
                    Text("Today's Pick")
                        .font(.headline)
                        .padding(.top)
                        .foregroundColor(AppTheme.highlight)
                    
                    if let pick = recipeOfTheDay {
                        NavigationLink(destination: RecipeDetailView(recipe: pick)) {
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppTheme.card.opacity(0.9),
                                                Color.orange.opacity(0.25)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 220)
                                    .shadow(color: AppTheme.softShadow, radius: 8, y: 3)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(pick.name)
                                        .font(.title2.bold())
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text("\(pick.base) • \(pick.style)")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                .padding()
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        ProgressView("Loading recipe of the day...")
                            .frame(height: 200)
                            .padding(.horizontal)
                    }


                    Group {
                        // Base
                        Text("Base")
                            .font(.headline)
                            .foregroundColor(AppTheme.highlight)
                            .padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            MultiSelectChips(options: bases, selection: $selectedBases)
                                .padding(.horizontal)
                                
                        }
                        
                        // Style
                        Text("Style")
                            .font(.headline)
                            .foregroundColor(AppTheme.highlight)
                            .padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            MultiSelectChips(options: styles, selection: $selectedStyles)
                                .padding(.horizontal)
                        }
                        
                        // Flavor
                        Text("Flavor")
                            .font(.headline)
                            .foregroundColor(AppTheme.highlight)
                            .padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            MultiSelectChips(options: flavors, selection: $selectedFlavors)
                                .padding(.horizontal)
                            
                        }
                    }
                    
                    NavigationLink(
                        destination: RecommendationView(results: recommendations, allRecipes: allRecipes)
                    ) {
                        Text("Match")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.accent)
                            .cornerRadius(14)
                            .shadow(color: AppTheme.softShadow, radius: 6, y: 3)
                            .padding(.vertical)
                        
                    }
                    .simultaneousGesture(TapGesture().onEnded(runRecommendation))
                    
                }
                .padding(.horizontal)
                
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .shadow(color: AppTheme.softShadow, radius: 3, y: 1)
            
            .onAppear {
                allRecipes = RecipeLoader.loadDefaultRecipes()
                //print("Loaded \(allRecipes.count) recipes from CocktailCore.")
                //print("Bases:", bases)
                //print("Styles:", styles)
                //print("Flavors:", flavors)
                
                // 🧠 Combine user + default recipes
                let all = store.defaultRecipes + store.userRecipes
                
                // 🌟 Load random recipe of the day
                recipeOfTheDay = rotd.today(from: all)
                                
            }
        }

    }


    // MARK: - Run Recommendation
    private func runRecommendation() {
        var q = RankParams()

        // Convert selectedBases back to canonical (remove spaces, lowercase)
        q.baseNames = Array(selectedBases.map { $0.replacingOccurrences(of: " ", with: "_").lowercased() })
        q.styleNames = Array(selectedStyles.map { $0.replacingOccurrences(of: " ", with: "_").lowercased() })
        q.flavorHighlights = Array(selectedFlavors.map { $0.replacingOccurrences(of: " ", with: "_").lowercased() })

        q.keywords = searchText
        q.topK = 10

        recommendations = Recommender.rank(recipes: allRecipes, params: q)

        if let first = allRecipes.first?.flavor_vector?.order {
            print("Flavor vector order:", first)
        }

        print("Found \(recommendations.count) matches")
        print("Selected flavors:", selectedFlavors)
    }

}

//// MARK: - JSON Loader
//func loadRecipes() -> [Recipe] {
//    guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json"),
//          let data = try? Data(contentsOf: url) else {
//        print(" Could not load recipes.json")
//        return []
//    }
//    return (try? JSONDecoder().decode([Recipe].self, from: data)) ?? []
//}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserSession())
            .environmentObject(RecipeStore())
    }
}
