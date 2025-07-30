//
//  Constants.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import Foundation

/// Global configuration endpoint for fetching backend domain
let globalConfigEndpoint = "https://onboardsync-backend.vercel.app/api/global-config"

/// UserDefaults keys used by the SDK
enum UserDefaultsKeys {
    /// Key for storing completion status
    static let onboardingCompleted = "onboardingCompleted"
    
    /// Key for storing device ID
    static let deviceId = "onboardSyncDeviceId"
}

/// JavaScript message handler names
enum JSMessageHandler {
    /// The channel name for JavaScript bridge communication
    /// Note: This uses "flutter_bridge" for cross-platform compatibility
    static let onboardingChannel = "flutter_bridge"
}