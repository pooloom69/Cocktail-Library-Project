//
//  Recommender.swift
//  CocktailLibrary
//
//  Created by Sola Lhim on 2025-10-21.
//

import Foundation

// MARK: - Rank Parameter
public struct RankParams {
    // Query vectors (optional)
    public var flavorQVec: [Double]?
    public var styleQVec: [Double]?
    public var baseQVec: [Double]?

    // Query by names / highlights
    public var baseNames: [String] = []
    public var styleNames: [String] = []
    public var flavorHighlights: [String] = []

    // Hard filters
    public var hardBase: String?
    public var hardStyle: String?
    public var abvRange: (Double, Double)?

    // Optional keyword re-rank
    public var keywords: String?

    // Weights
    public var wFlavor: Double = 0.60
    public var wStyle:  Double = 0.25
    public var wBase:   Double = 0.15
    public var wKW:     Double = 0.10   // keyword weight (optional)

    // Top results
    public var topK: Int = 12

    public init() {}
}

// MARK: - Rank Result
public struct RankResult: Codable, Hashable {
    public let id: String
    public let name: String
    public let score: Double
    public let explain: Explain
    
    public init(id: String, name: String, score: Double, explain: Explain) {
        self.id = id
        self.name = name
        self.score = score
        self.explain = explain
    }

    public struct Explain: Codable, Hashable {
        public let flavorSim: Double
        public let styleSim: Double
        public let baseSim: Double
        public let kwBoost: Double
        
        public init(flavorSim: Double, styleSim: Double, baseSim: Double, kwBoost: Double) {
            self.flavorSim = flavorSim
            self.styleSim = styleSim
            self.baseSim = baseSim
            self.kwBoost = kwBoost
        }
    }
}

// MARK: - Recommender Engine
public enum Recommender {

    // Cosine similarity ∈ [0, 1]
    private static func cosine(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0.0 }
        var num = 0.0, na = 0.0, nb = 0.0
        for i in 0..<a.count {
            num += a[i] * b[i]
            na  += a[i] * a[i]
            nb  += b[i] * b[i]
        }
        guard na > 0, nb > 0 else { return 0.0 }
        return max(0.0, min(1.0, num / (sqrt(na) * sqrt(nb))))
    }

    // Convert highlights to binary vector
    private static func vecFromHighlights(order: [String], highlights: [String]) -> [Double] {
        let want = Set(highlights.map { $0.lowercased() })
        return order.map { want.contains($0.lowercased()) ? 1.0 : 0.0 }
    }

    // Keyword-based mini score
    private static func keywordScore(text: String, terms: [String]) -> Double {
        guard !terms.isEmpty else { return 0.0 }
        let hay = text.lowercased()
        var score = 0.0
        for term in terms.map({ $0.lowercased() }).filter({ !$0.isEmpty }) {
            var searchRange: Range<String.Index>? = hay.startIndex..<hay.endIndex
            while let r = hay.range(of: term, options: [], range: searchRange) {
                score += 1.0
                searchRange = r.upperBound..<hay.endIndex
            }
        }
        return score
    }

    // MARK: - Rank Function
    public static func rank(recipes: [Recipe], params p: RankParams) -> [RankResult] {
        guard let first = recipes.first else { return [] }

        // Build query vectors if not provided
        var flavorQ = p.flavorQVec
        var styleQ  = p.styleQVec
        var baseQ   = p.baseQVec

        if flavorQ == nil, !p.flavorHighlights.isEmpty,
           let order = first.flavor_vector?.order {
            flavorQ = vecFromHighlights(order: order, highlights: p.flavorHighlights)
        }
        if styleQ == nil, !p.styleNames.isEmpty,
           let order = first.style_vector?.order {
            styleQ = vecFromHighlights(order: order, highlights: p.styleNames)
        }
        if baseQ == nil, !p.baseNames.isEmpty,
           let order = first.base_vector?.order {
            baseQ = vecFromHighlights(order: order, highlights: p.baseNames)
        }

        // Temporary structure for ranking
        struct Tmp {
            var id: String
            var name: String
            var flavorSim: Double
            var styleSim: Double
            var baseSim: Double
            var vecScore: Double
            var kwRaw: Double
            var recipeIndex: Int
        }

        var tmp: [Tmp] = []
        tmp.reserveCapacity(recipes.count)

        // 1️⃣ Compute similarities
        for (idx, r) in recipes.enumerated() {
            // Hard filters
            if let hb = p.hardBase, r.base.lowercased() != hb.lowercased() { continue }
            if let hs = p.hardStyle, r.style.lowercased() != hs.lowercased() { continue }
            if let range = p.abvRange, !(range.0...range.1).contains(r.abv) { continue }

            // Compute vector similarities (safe unwrapping)
            let fSim = (flavorQ != nil && r.flavor_vector?.vector != nil)
                ? cosine(flavorQ!, r.flavor_vector!.vector)
                : 0.0
            let sSim = (styleQ != nil && r.style_vector?.vector != nil)
                ? cosine(styleQ!, r.style_vector!.vector)
                : 0.0
            let bSim = (baseQ != nil && r.base_vector?.vector != nil)
                ? cosine(baseQ!, r.base_vector!.vector)
                : 0.0

            let vecScore = p.wFlavor * fSim + p.wStyle * sSim + p.wBase * bSim

            tmp.append(Tmp(
                id: r.id,
                name: r.name,
                flavorSim: fSim,
                styleSim: sSim,
                baseSim: bSim,
                vecScore: vecScore,
                kwRaw: 0.0,
                recipeIndex: idx
            ))
        }
        
        print("Similarities:")
        for t in tmp {
            print("• \(t.name): flavorSim = \(t.flavorSim), styleSim = \(t.styleSim), baseSim = \(t.baseSim), total = \(t.vecScore)")
        }

        // 2️⃣ Sort by vector similarity
        tmp.sort { $0.vecScore > $1.vecScore }
        let limit = max(p.topK * 3, p.topK)
        if tmp.count > limit { tmp = Array(tmp.prefix(limit)) }

        // 3️⃣ Optional keyword re-rank
        var terms: [String] = []
        if let kw = p.keywords,
           !kw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            terms = kw.split(whereSeparator: \.isWhitespace).map(String.init)
        }

        if !terms.isEmpty {
            var maxKW = 0.0
            for i in 0..<tmp.count {
                let r = recipes[tmp[i].recipeIndex]
                var blob = "\(r.name) \(r.base) \(r.style) " + r.flavor.joined(separator: " ")
                blob += " " + r.ingredients.map { $0.name }.joined(separator: " ")
                blob += " " + r.steps.joined(separator: " ")
                blob += " " + r.garnish.joined(separator: " ")
                tmp[i].kwRaw = keywordScore(text: blob, terms: terms)
                maxKW = max(maxKW, tmp[i].kwRaw)
            }

            tmp.sort {
                let aScore = $0.vecScore + p.wKW * (($0.kwRaw > 0 && maxKW > 0) ? $0.kwRaw / maxKW : 0)
                let bScore = $1.vecScore + p.wKW * (($1.kwRaw > 0 && maxKW > 0) ? $1.kwRaw / maxKW : 0)
                return aScore > bScore
            }
        }

        // 4️⃣ Final top K results
        let final = tmp.prefix(p.topK).map { t -> RankResult in
            let total = t.vecScore + (t.kwRaw > 0 ? p.wKW : 0.0)
            return RankResult(
                id: t.id,
                name: t.name,
                score: (total * 1_000_000).rounded() / 1_000_000,
                explain: .init(
                    flavorSim: (t.flavorSim * 1000).rounded() / 1000,
                    styleSim:  (t.styleSim  * 1000).rounded() / 1000,
                    baseSim:   (t.baseSim   * 1000).rounded() / 1000,
                    kwBoost:   (t.kwRaw > 0 ? 1.0 : 0.0)
                )
            )
        }

        
        return Array(final)
    }
}

