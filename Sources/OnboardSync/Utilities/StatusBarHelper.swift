//
//  StatusBarHelper.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import UIKit

/// Helper for managing status bar appearance
final class StatusBarHelper {
    
    /// Store the original interface style to restore later
    private static var originalInterfaceStyle: UIUserInterfaceStyle?
    
    /// Updates the status bar style based on whether light content is needed
    /// - Parameter needsLightContent: true if status bar should show light content (white text/icons on dark background)
    static func updateStatusBar(needsLightContent: Bool) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                
                // Store original style on first call
                if originalInterfaceStyle == nil {
                    originalInterfaceStyle = window.overrideUserInterfaceStyle
                }
                
                window.overrideUserInterfaceStyle = needsLightContent ? .dark : .light
            }
        }
    }
    
    /// Restores the original interface style
    static func restoreOriginalStyle() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let originalStyle = originalInterfaceStyle {
                window.overrideUserInterfaceStyle = originalStyle
                originalInterfaceStyle = nil
            }
        }
    }
}