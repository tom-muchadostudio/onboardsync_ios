//
//  OnboardSync.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import SwiftUI
import UIKit

/// Main class for the OnboardSync SDK
///
/// This class provides the primary interface for integrating OnboardSync
/// into your iOS application. It handles displaying remotely configured
/// onboarding flows with automatic fallback support.
///
/// Example usage:
/// ```swift
/// OnboardSync.showOnboarding(
///     config: OnboardSyncConfig(
///         projectId: "your-project-id",
///         secretKey: "your-secret-key"
///     )
/// )
/// ```
public class OnboardSync: ObservableObject {
    
    // Tracks if onboarding is already showing to prevent multiple instances
    private static var isOnboardingShowing = false
    
    /// Displays the onboarding flow for the specified project
    ///
    /// This method is the main entry point for showing onboarding in your app.
    /// It handles:
    /// - Checking if onboarding has already been completed
    /// - Fetching the appropriate onboarding flow configuration
    /// - Displaying the onboarding in a WebView
    /// - Falling back to a simple welcome screen on errors
    /// - Saving completion status for future app launches
    ///
    /// - Parameter config: Configuration object containing project details and options
    @MainActor
    public static func showOnboarding(config: OnboardSyncConfig) {
        
        guard !isOnboardingShowing else {
            debugPrint("[OnboardSync] Onboarding already active, ignoring call")
            return
        }
        
        // Check if onboarding was previously completed
        if !config.testingEnabled {
            let hasCompleted = UserDefaults.standard.bool(forKey: UserDefaultsKeys.onboardingCompleted)
            if hasCompleted {
                debugPrint("[OnboardSync] Onboarding already completed, skipping")
                return
            }
        } else {
            debugPrint("[OnboardSync] Testing mode: ignoring completion status")
        }
        
        isOnboardingShowing = true
        
        // Get the key window and root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            debugPrint("[OnboardSync] Could not find root view controller")
            isOnboardingShowing = false
            return
        }
        
        // Get background color from the current view
        let backgroundColor = Color(rootViewController.view.backgroundColor ?? .systemBackground)
        
        Task {
            do {
                // 1. Fetch backend domain
                let backendDomain = try await fetchBackendDomain(config: config)
                
                // 2. Get device ID
                let deviceId = DeviceIDManager.getOrGenerateDeviceID()
                
                // 3. Resolve flow ID
                let flowId = try await resolveFlowId(
                    backendDomain: backendDomain,
                    projectId: config.projectId,
                    deviceId: deviceId
                )
                
                // 4. Construct URL
                let url = "\(backendDomain)/onboarding/\(flowId)/1?deviceId=\(deviceId)"
                
                // 5. Get app name
                let appName = getAppName()
                
                // 6. Present onboarding
                await MainActor.run {
                    let onboardingView = WebViewScreen(
                        initialURL: url,
                        testingEnabled: config.testingEnabled,
                        appName: appName,
                        backgroundColor: backgroundColor,
                        onComplete: { result in
                            // Restore style immediately when complete is triggered
                            StatusBarHelper.restoreOriginalStyle()
                            config.onComplete?(result)
                        }
                    )
                    
                    let hostingController = UIHostingController(rootView: onboardingView)
                    hostingController.modalPresentationStyle = .fullScreen
                    rootViewController.present(hostingController, animated: true) {
                        // Presentation completed
                    }
                    
                    // Monitor when the hosting controller is dismissed
                    Task { @MainActor in
                        while hostingController.presentingViewController != nil {
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                        }
                        isOnboardingShowing = false
                        debugPrint("[OnboardSync] Onboarding view dismissed")
                    }
                }
                
            } catch {
                debugPrint("[OnboardSync] Error: \(error)")
                await MainActor.run {
                    showFallback(
                        from: rootViewController,
                        config: config,
                        backgroundColor: backgroundColor
                    )
                }
            }
        }
    }
    
    /// Fetches the backend domain from the global configuration endpoint
    /// - Parameter config: The OnboardSync configuration containing API credentials
    /// - Returns: The backend domain URL string
    /// - Throws: OnboardSyncError if the fetch fails or returns invalid data
    private static func fetchBackendDomain(config: OnboardSyncConfig) async throws -> String {
        guard let url = URL(string: globalConfigEndpoint) else {
            throw OnboardSyncError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: config.secretKey),
            URLQueryItem(name: "projectId", value: config.projectId)
        ]
        
        guard let finalURL = components?.url else {
            throw OnboardSyncError.invalidURL
        }
        
        debugPrint("[OnboardSync] Fetching config from: \(finalURL)")
        
        let (data, response) = try await URLSession.shared.data(from: finalURL)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OnboardSyncError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OnboardSyncError.configFetchFailed(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        let configResponse = try JSONDecoder().decode(ConfigResponse.self, from: data)
        
        guard !configResponse.backendDomain.isEmpty else {
            throw OnboardSyncError.emptyBackendDomain
        }
        
        debugPrint("[OnboardSync] Backend domain: \(configResponse.backendDomain)")
        return configResponse.backendDomain
    }
    
    /// Resolves the appropriate flow ID for the given project and device
    /// - Parameters:
    ///   - backendDomain: The backend domain URL
    ///   - projectId: The OnboardSync project ID
    ///   - deviceId: The unique device identifier
    /// - Returns: The flow ID to use for this device
    /// - Throws: OnboardSyncError if the resolution fails
    private static func resolveFlowId(backendDomain: String, projectId: String, deviceId: String) async throws -> String {
        let urlString = "\(backendDomain)/api/onboarding/resolve"
        guard let url = URL(string: urlString) else {
            throw OnboardSyncError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "projectId", value: projectId),
            URLQueryItem(name: "deviceId", value: deviceId)
        ]
        
        guard let finalURL = components?.url else {
            throw OnboardSyncError.invalidURL
        }
        
        debugPrint("[OnboardSync] Resolving flow: \(finalURL)")
        
        let (data, response) = try await URLSession.shared.data(from: finalURL)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OnboardSyncError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw OnboardSyncError.noFlowConfigured
            }
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OnboardSyncError.flowResolutionFailed(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        let flowResponse = try JSONDecoder().decode(FlowResolutionResponse.self, from: data)
        
        debugPrint("[OnboardSync] Flow ID: \(flowResponse.flowId)")
        return flowResponse.flowId
    }
    
    @MainActor
    private static func showFallback(from viewController: UIViewController, config: OnboardSyncConfig, backgroundColor: Color) {
        let appName = getAppName()
        
        let fallbackView = FallbackView(
            appName: appName,
            backgroundColor: backgroundColor,
            onComplete: { _ in
                // Restore style immediately when complete is triggered
                StatusBarHelper.restoreOriginalStyle()
                // Fallback has no form data, so pass nil
                config.onComplete?(nil)
            }
        )
        
        let hostingController = UIHostingController(rootView: fallbackView)
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: true) {
            // Presentation completed
        }
        
        // Monitor when the hosting controller is dismissed
        Task { @MainActor in
            while hostingController.presentingViewController != nil {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            isOnboardingShowing = false
            debugPrint("[OnboardSync] Fallback view dismissed")
        }
        
        debugPrint("[OnboardSync] Showing fallback screen")
    }
    
    private static func getAppName() -> String {
        // First try to get the display name
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return appName
        }
        
        // Fall back to bundle name and format it
        if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            // Convert snake_case or kebab-case to Title Case
            let formatted = bundleName
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
                .split(separator: " ")
                .map { word in
                    word.prefix(1).uppercased() + word.dropFirst().lowercased()
                }
                .joined(separator: " ")
            return formatted
        }
        
        return "Your App"
    }
}

// MARK: - Error Types
enum OnboardSyncError: LocalizedError {
    case invalidURL
    case invalidResponse
    case configFetchFailed(statusCode: Int, message: String)
    case emptyBackendDomain
    case noFlowConfigured
    case flowResolutionFailed(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .configFetchFailed(let statusCode, let message):
            return "Config fetch failed (\(statusCode)): \(message)"
        case .emptyBackendDomain:
            return "Empty backend domain received"
        case .noFlowConfigured:
            return "No onboarding flow configured for this project"
        case .flowResolutionFailed(let statusCode, let message):
            return "Flow resolution failed (\(statusCode)): \(message)"
        }
    }
}