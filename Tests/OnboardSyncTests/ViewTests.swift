//
//  ViewTests.swift
//  OnboardSyncTests
//
//  Created by OnboardSync on 2025-01-19.
//

import XCTest
import SwiftUI
@testable import OnboardSync

final class ViewTests: XCTestCase {
    
    // MARK: - Loading View Tests
    
    func testLoadingViewInitialization() {
        let loadingView = LoadingView(
            appName: "Test App",
            backgroundColor: .white
        )
        
        // Create a hosting controller to test the view
        let hostingController = UIHostingController(rootView: loadingView)
        
        // Load view
        _ = hostingController.view
        
        // Check that view is configured
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - Fallback View Tests
    
    func testFallbackViewInitialization() {
        var completionCalled = false
        let fallbackView = FallbackView(
            appName: "Test App",
            backgroundColor: .white,
            onComplete: { completionCalled = true }
        )
        
        // Create a hosting controller to test the view
        let hostingController = UIHostingController(rootView: fallbackView)
        
        // Load view
        _ = hostingController.view
        
        // Check that view is configured
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - WebView Screen Tests
    
    func testWebViewScreenInitialization() {
        let webViewScreen = WebViewScreen(
            initialURL: "https://example.com",
            testingEnabled: false,
            appName: "Test App",
            backgroundColor: .white,
            onComplete: nil
        )
        
        // Create a hosting controller to test the view
        let hostingController = UIHostingController(rootView: webViewScreen)
        
        // Load view
        _ = hostingController.view
        
        // Check that view is configured
        XCTAssertNotNil(hostingController.view)
    }
}