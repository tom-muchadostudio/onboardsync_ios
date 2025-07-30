//
//  ColorUtils.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import SwiftUI

/// Utility functions for color-related operations
final class ColorUtils {
    
    /// Determines if a color should be considered "dark" based on its luminance
    /// - Parameter color: The Color to check
    /// - Returns: true if the color's luminance is below 0.5
    static func isDarkColor(_ color: Color) -> Bool {
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(color)
        return isDark(uiColor)
    }
    
    /// Determines if a UIColor should be considered "dark" based on its luminance
    /// - Parameter color: The UIColor to check
    /// - Returns: true if the color's luminance is below 0.5
    static func isDark(_ color: UIColor) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate luminance using the formula: 0.2126 * R + 0.7152 * G + 0.0722 * B
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        
        return luminance < 0.5
    }
}