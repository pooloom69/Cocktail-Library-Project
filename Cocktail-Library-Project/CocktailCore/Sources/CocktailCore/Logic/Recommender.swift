// Recommender.swift
// Swift 5 / iOS compatible – no third-party deps

import Foundation

// MARK: - Data Model

public struct VectorBlock: Codable {
    public let scale: String?
    public let order: [String]
    public let vector: [Double]
    public let version: Int?
}

public struct Ingredient: Codable {
    public let name: String
    public let amount: Double?
    public let unit: String?
}

public struct Drink: Codable {
    public let id: String
    public let name: String
    public let base: String
    public let style: String
    /// Highlighted flavors (subset, ordered according to flavor_vector.order)
    public let flavor: [String]

    public let base_vector: VectorBlock
    public let style_vector: VectorBlock
    public let flavor_vector: VectorBlock

    public let abv: Double?
    public let ice: String?
    public let ingredients: [Ingredient]?
    public let steps: [String]?
    public let glass: String?
    public let garnish: [String]?
}

// MARK: - Query & Result Types

public struct RankParams {
    // Query-by-vectors (optional)
    public var flavorQVec: [Double]?
    public var styleQVec:  [Double]?
    public var baseQVec:   [Double]?

    // Or query-by-names/highlights (converted to vectors using .order)
    public var baseNames: [String] = []           // e.g. ["tequila"]
    public var styleNames: [String] = []          // e.g. ["sour"]
    public var flavorHighlights: [String] = []    // e.g. ["sweet","sour","salty"]

    // Hard filters on top-level strings (exact match)
    public var hardBase: String?
    public var hardStyle: String?

    // Optional ABV range
    public var abvRange: (Double, Double)?

    // Optional keyword re-rank
    public var keywords: String?

    // Weights
    public var wFlavor: Double = 0.60
    public var wStyle:  Double = 0.25
    public var wBase:   Double = 0.15
    public var wKW:     Double = 0.10   // applied only if keywords provided

    public var topK: Int = 12

    public init() {}
}

public struct RankResult: Codable {
    public let id: String
    public let name: String
    public let score: Double
    public let explain: Explain

    public struct Explain: Codable {
        public let flavorSim: Double
        public let styleSim: Double
        public let baseSim: Double
        public let kwBoost: Double
    }
}

// MARK: - Recommender

public enum Recommender {

    // Cosine similarity in [0, 1]
    private static func cosine(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0.0 }
        var num = 0.0, na = 0.0, nb = 0.0
        for i in 0..<a.count {
            num += a[i] * b[i]
            na  += a[i] * a[i]
            nb  += b[i] * b[i]
        }
        guard na > 0, nb > 0 else { return 0.0 }
        let den = sqrt(na) * sqrt(nb)
        let v = num / den
        return min(1.0, max(0.0, v))
    }

    // Build a 0/1 vector from highlights, aligned to the given order
    private static func vecFromHighlights(order: [String], highlights: [String], on: Double = 1.0, off: Double = 0.0) -> [Double] {
        let want = Set(highlights.map { $0.lowercased() })
        return order.map { want.contains($0.lowercased()) ? on : off }
    }

    // Tiny keyword scorer (frequency)
    private static func keywordScore(text: String, terms: [String]) -> Double {
        guard !terms.isEmpty else { return 0.0 }
        let hay = text.lowercased()
        var score = 0.0
        for t in terms.map({ $0.lowercased() }).filter({ !$0.isEmpty }) {
            var searchRange: Range<String.Index>? = hay.startIndex..<hay.endIndex
            while let r = hay.range(of: t, options: [], range: searchRange) {
                score += 1.0
                searchRange = r.upperBound..<hay.endIndex
            }
        }
        return score
    }

    /// Rank drinks by flavor/style/base vectors with optional hard filters and keyword re-rank.
    public static func rank(drinks: [Drink], params p: RankParams) -> [RankResult] {
        guard let first = drinks.first else { return [] }

        // Build query vectors if not provided
        var flavorQ = p.flavorQVec
        var styleQ  = p.styleQVec
        var baseQ   = p.baseQVec

        if flavorQ == nil, !p.flavorHighlights.isEmpty {
            flavorQ = vecFromHighlights(order: first.flavor_vector.order, highlights: p.flavorHighlights)
        }
        if styleQ == nil, !p.styleNames.isEmpty {
            styleQ = vecFromHighlights(order: first.style_vector.order, highlights: p.styleNames)
        }
        if baseQ == nil, !p.baseNames.isEmpty {
            baseQ = vecFromHighlights(order: first.base_vector.order, highlights: p.baseNames)
        }

        struct Tmp {
            var id: String
            var name: String
            var flavorSim: Double
            var styleSim: Double
            var baseSim: Double
            var vecScore: Double
            var kwRaw: Double
            var drinkIndex: Int
        }

        var tmp: [Tmp] = []
        tmp.reserveCapacity(drinks.count)

        for (idx, d) in drinks.enumerated() {

            // Hard filters
            if let hb = p.hardBase, d.base.lowercased() != hb.lowercased() { continue }
            if let hs = p.hardStyle, d.style.lowercased() != hs.lowercased() { continue }

            // ABV range
            if let range = p.abvRange, let abv = d.abv {
                if !(range.0...range.1).contains(abv) { continue }
            }

            // Vector similarities
            let fSim = (flavorQ != nil) ? cosine(flavorQ!, d.flavor_vector.vector) : 0.0
            let sSim = (styleQ  != nil) ? cosine(styleQ!,  d.style_vector.vector)  : 0.0
            let bSim = (baseQ   != nil) ? cosine(baseQ!,   d.base_vector.vector)   : 0.0
            let vecScore = p.wFlavor * fSim + p.wStyle * sSim + p.wBase * bSim

            tmp.append(Tmp(
                id: d.id,
                name: d.name,
                flavorSim: fSim,
                styleSim: sSim,
                baseSim: bSim,
                vecScore: vecScore,
                kwRaw: 0.0,
                drinkIndex: idx
            ))
        }

        // Phase 1: by vector score
        tmp.sort { $0.vecScore > $1.vecScore }
        let keepHeadroom = max(p.topK * 3, p.topK)
        if tmp.count > keepHeadroom { tmp = Array(tmp.prefix(keepHeadroom)) }

        // Phase 2: keyword re-rank (optional)
        var useKW = false
        var terms: [String] = []
        if let kw = p.keywords, !kw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            terms = kw.split(whereSeparator: \.isWhitespace).map(String.init)
            useKW = true
        }

        if useKW, !tmp.isEmpty {
            var maxKW = 0.0
            for i in 0..<tmp.count {
                let d = drinks[tmp[i].drinkIndex]
                // Build a simple searchable blob
                var blob = "\(d.name) \(d.base) \(d.style) "
                blob += d.flavor.joined(separator: " ") + " "
                if let ing = d.ingredients {
                    for g in ing { blob += (g.name + " ") }
                }
                if let steps = d.steps { blob += steps.joined(separator: " ") + " " }
                if let garnish = d.garnish { blob += garnish.joined(separator: " ") + " " }
                tmp[i].kwRaw = keywordScore(text: blob, terms: terms)
                maxKW = max(maxKW, tmp[i].kwRaw)
            }
            // Normalize KW to [0,1] in this candidate set and combine
            tmp.sort {
                let aScore = $0.vecScore + p.wKW * ((maxKW > 0) ? $0.kwRaw / maxKW : 0.0)
                let bScore = $1.vecScore + p.wKW * ((maxKW > 0) ? $1.kwRaw / maxKW : 0.0)
                return aScore > bScore
            }
        }

        // Finalize
        let final = tmp.prefix(p.topK).map { t -> RankResult in
            let kwNorm = useKW ? (t.kwRaw > 0 ? 1.0 : 0.0) : 0.0 // we don't expose raw; kw effect is in sort
            let total = t.vecScore + (useKW ? p.wKW * kwNorm : 0.0)
            return RankResult(
                id: t.id,
                name: t.name,
                score: (total * 1_000_000).rounded() / 1_000_000, // round for stability
                explain: .init(
                    flavorSim: (t.flavorSim * 1000).rounded() / 1000,
                    styleSim:  (t.styleSim  * 1000).rounded() / 1000,
                    baseSim:   (t.baseSim   * 1000).rounded() / 1000,
                    kwBoost:   (kwNorm      * 1000).rounded() / 1000
                )
            )
        }
        return Array(final)
    }
}


    /*      Chat GPT provided this so we can link to the IOS app
// 1) Decode your JSON catalog (array of Drink) with JSONDecoder
let data: Data = /* load from bundle / disk / network */
let catalog = try JSONDecoder().decode([Drink].self, from: data)

// 2) Typical query: base + style + flavor highlights
var q = RankParams()
q.baseNames = ["tequila"]
q.styleNames = ["sour"]
q.flavorHighlights = ["sweet","sour","salty"]   // ordered internally to your .order
q.hardStyle = "Sour"                            // optional strict filter
q.abvRange = (0.12, 0.24)                       // optional
q.topK = 10

let results = Recommender.rank(drinks: catalog, params: q)

// 3) “Like this drink” – copy its vectors as the query
if let seed = catalog.first(where: { $0.id == "negroni_classic" }) {
    var q2 = RankParams()
    q2.flavorQVec = seed.flavor_vector.vector
    q2.styleQVec  = seed.style_vector.vector
    q2.baseQVec   = seed.base_vector.vector
    q2.topK = 10
    let similar = Recommender.rank(drinks: catalog, params: q2)
}

// 4) Add keyword re-rank later (lightweight)
var q3 = q
q3.keywords = "pineapple orgeat crushed ice"
let resultsWithKW = Recommender.rank(drinks: catalog, params: q3)  */
