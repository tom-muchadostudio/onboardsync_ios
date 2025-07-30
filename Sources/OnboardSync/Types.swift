//
//  Types.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import Foundation

/// Callback triggered when onboarding is completed
public typealias OnboardingCompleteCallback = () -> Void

/// Configuration for the OnboardSync SDK
public struct OnboardSyncConfig {
    /// Your OnboardSync project ID
    public let projectId: String
    
    /// Your OnboardSync secret key
    public let secretKey: String
    
    /// If true, shows onboarding every time regardless of completion status
    public let testingEnabled: Bool
    
    /// Optional callback when onboarding completes
    public let onComplete: OnboardingCompleteCallback?
    
    public init(projectId: String, 
                secretKey: String, 
                testingEnabled: Bool = false,
                onComplete: OnboardingCompleteCallback? = nil) {
        self.projectId = projectId
        self.secretKey = secretKey
        self.testingEnabled = testingEnabled
        self.onComplete = onComplete
    }
}

/// Response from the global config endpoint
internal struct ConfigResponse: Codable {
    let backendDomain: String
}

/// Response from the flow resolution endpoint
internal struct FlowResolutionResponse: Codable {
    let flowId: String
}