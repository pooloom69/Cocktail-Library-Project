//
//  ThemeView.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 11/8/25.
//
import SwiftUI

enum AppTheme {
    // MARK: - Base
    static let background = Color(red: 0.982, green: 0.972, blue: 0.955) // 따뜻한 크림 베이지
    static let card = Color(red: 1.0, green: 0.992, blue: 0.982)        // 종이 같은 밝은 톤

    // MARK: - Accent Gradient (Mauve Brown → Dusty Rose)
    static let accent = LinearGradient(
        colors: [
            Color(red: 0.55, green: 0.45, blue: 0.55), // Mauve Brown (브라운 섞인 퍼플)
            Color(red: 0.82, green: 0.68, blue: 0.66)  // Dusty Rose
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Text (잉크톤)
    static let textPrimary = Color(red: 0.25, green: 0.20, blue: 0.18)   // 따뜻한 다크 브라운 잉크
    static let textSecondary = Color(red: 0.46, green: 0.40, blue: 0.38) // 라떼 브라운

    // MARK: - Highlights
    static let highlight = Color(red: 0.52, green: 0.42, blue: 0.58)     // Vintage Plum 💜 (포인트용)
    static let chipSelected = Color(red: 0.84, green: 0.76, blue: 0.78).opacity(0.45) // Mauve hint tone

    // MARK: - Surfaces
    static let tabBar = Color(red: 0.985, green: 0.975, blue: 0.96)
    static let divider = Color(red: 0.92, green: 0.9, blue: 0.88)
    static let softShadow = Color(red: 0.45, green: 0.35, blue: 0.38).opacity(0.15)

    // MARK: - Fonts
    static func titleFont() -> Font {
        .system(.largeTitle, design: .serif).weight(.semibold)
    }
    static func bodyFont() -> Font {
        .system(.body, design: .rounded)
    }
}


//import SwiftUI
//
//enum AppTheme {
//    // MARK: - Colors
//    static let background = Color(red: 0.98, green: 0.97, blue: 0.94) // 크림 베이스
//    static let card = Color.white
//    static let accent = LinearGradient(
//        colors: [
//            Color(red: 0.90, green: 0.75, blue: 0.55), // 골드베이지
//            Color(red: 0.80, green: 0.65, blue: 0.45)  // 라이트 모카
//        ],
//        startPoint: .topLeading,
//        endPoint: .bottomTrailing
//    )
//
//    static let textPrimary = Color(red: 0.20, green: 0.18, blue: 0.15)   // 잉크 브라운
//    static let textSecondary = Color(red: 0.45, green: 0.40, blue: 0.35) // 부드러운 브라운그레이
//    static let highlight = Color(red: 0.75, green: 0.55, blue: 0.35)     // 따뜻한 카라멜 포인트
//    static let chipSelected = Color(red: 0.90, green: 0.80, blue: 0.65).opacity(0.35)
//
//    static let tabBar = Color(red: 0.99, green: 0.98, blue: 0.96)
//    static let softShadow = Color.black.opacity(0.08)
//
//    // MARK: - Fonts
//    static func titleFont() -> Font {
//        .system(.largeTitle, design: .rounded).weight(.semibold)
//    }
//    static func bodyFont() -> Font {
//        .system(.body, design: .rounded)
//    }
//}
//
