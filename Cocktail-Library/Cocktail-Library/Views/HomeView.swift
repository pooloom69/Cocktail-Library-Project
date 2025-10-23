import SwiftUI
import CocktailCore

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedBases: Set<String> = []
    @State private var selectedStyles: Set<String> = []
    @State private var selectedFlavors: Set<String> = []
    @State private var allRecipes: [Recipe] = []
    @State private var recommendations: [RankResult] = []

    
    @EnvironmentObject var store: RecipeStore
    
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
                    // Title
                    Text("Cocktail Library")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    Text("Today's Pick")
                        .font(.headline)
                        .padding(.top)
                    
                    // Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                            .frame(height: 200)
                            .shadow(radius: 3)
                    }
                    
                    //                Text("Find your Recipe")
                    //                    .font(.headline)
                    //                    .padding(.top, 12)
                    //
                    // Search Bar
                    //                SearchBar(text: $searchText)
                    //                    .padding(.top, 15)
                    //
                    // Filters
                    Group {
                        // Base
                        Text("Base").font(.headline).padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            MultiSelectChips(options: bases, selection: $selectedBases)
                                .padding(.horizontal)
                                
                        }
                        
                        // Style
                        Text("Style").font(.headline).padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            MultiSelectChips(options: styles, selection: $selectedStyles)
                                .padding(.horizontal)
                        }
                        
                        // Flavor
                        Text("Flavor").font(.headline).padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            MultiSelectChips(options: flavors, selection: $selectedFlavors)
                                .padding(.horizontal)
                        }
                    }
                    
                    NavigationLink(
                        destination: RecommendationView(results: recommendations, allRecipes: allRecipes)
                    ) {
                        Text("Match")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                            .padding(.vertical)
                            .padding(.top)
                    }
                    .simultaneousGesture(TapGesture().onEnded(runRecommendation))
                    
                }
                .padding(.horizontal)
            }
            .onAppear {
                allRecipes = RecipeLoader.loadDefaultRecipes()
                //print("Loaded \(allRecipes.count) recipes from CocktailCore.")
                //print("Bases:", bases)
                //print("Styles:", styles)
                //print("Flavors:", flavors)
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
    }
}
