//
//  Color+Named.swift
//  UI
//
//  Extension for mapping string color names to SwiftUI Colors
//

import SwiftUI

import FunModel

extension Color {
    /// Creates a Color from an ItemColor enum value used in FeaturedItem data
    /// - Parameter itemColor: The ItemColor case to convert
    /// - Returns: Corresponding SwiftUI Color
    static func named(_ itemColor: ItemColor) -> Color {
        switch itemColor {
        case .green: return .green
        case .orange: return .orange
        case .blue: return .blue
        case .purple: return .purple
        case .indigo: return .indigo
        case .brown: return .brown
        case .teal: return .teal
        case .mint: return .mint
        case .cyan: return .cyan
        case .gray: return .gray
        case .red: return .red
        case .pink: return .pink
        case .yellow: return .yellow
        }
    }
}
