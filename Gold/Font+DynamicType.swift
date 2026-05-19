//
//  Font+DynamicType.swift
//  Gold
//
//  Dynamic Type font scale — all sizes here respond automatically to
//  the user's preferred text size (Settings > Accessibility > Larger Text).
//

internal import SwiftUI

// MARK: - Semantic font helpers

extension Font {
    // Hero / display — replaces hardcoded 44–56pt
    static func appDisplay(_ weight: Font.Weight = .heavy) -> Font {
        .largeTitle.weight(weight)
    }

    // Large titles — replaces hardcoded 28–34pt
    static func appTitle(_ weight: Font.Weight = .bold) -> Font {
        .title.weight(weight)
    }

    // Medium titles — replaces hardcoded 22–26pt
    static func appTitle2(_ weight: Font.Weight = .bold) -> Font {
        .title2.weight(weight)
    }

    // Small titles — replaces hardcoded 18–20pt
    static func appTitle3(_ weight: Font.Weight = .semibold) -> Font {
        .title3.weight(weight)
    }

    // Body / primary text — replaces hardcoded 15–17pt
    static func appBody(_ weight: Font.Weight = .regular) -> Font {
        .body.weight(weight)
    }

    // Subheadline — replaces hardcoded 14–15pt
    static func appSubheadline(_ weight: Font.Weight = .regular) -> Font {
        .subheadline.weight(weight)
    }

    // Footnote — replaces hardcoded 12–13pt
    static func appFootnote(_ weight: Font.Weight = .regular) -> Font {
        .footnote.weight(weight)
    }

    // Callout — replaces hardcoded 16pt
    static func appCallout(_ weight: Font.Weight = .regular) -> Font {
        .callout.weight(weight)
    }

    // Caption — replaces hardcoded 11–12pt
    static func appCaption(_ weight: Font.Weight = .regular) -> Font {
        .caption.weight(weight)
    }
}

// MARK: - ScaledMetric values for non-standard hero sizes

/// Use as @ScaledMetric(relativeTo: .largeTitle) var heroSize = AppFontSize.hero
enum AppFontSize {
    static let hero: CGFloat = 56       // very large display numbers
    static let display: CGFloat = 44    // large display numbers
    static let symbol: CGFloat = 120    // decorative icon/symbol
}
