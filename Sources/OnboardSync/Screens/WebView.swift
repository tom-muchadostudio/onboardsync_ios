//
//  WebView.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import SwiftUI
import WebKit
import StoreKit

/// SwiftUI wrapper for WKWebView to display onboarding content
struct WebView: UIViewRepresentable {
    let url: URL
    let testingEnabled: Bool
    @Binding var isInitialLoadComplete: Bool
    @Binding var showFallback: Bool
    @Binding var formResponses: OnboardingResult?
    let onComplete: OnboardingCompleteCallback?
    let backgroundColor: Color
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        
        // Add message handler for JavaScript bridge communication
        configuration.userContentController.add(context.coordinator, name: JSMessageHandler.onboardingChannel)
        
        // Inject CSS to set initial background color to prevent flash
        let isDark = ColorUtils.isDarkColor(backgroundColor)
        let bgColor = isDark ? "#000000" : "#FFFFFF"
        let textColor = isDark ? "#FFFFFF" : "#000000"
        
        let cssString = """
        body {
            background-color: \(bgColor) !important;
            color: \(textColor) !important;
        }
        """
        let cssScript = WKUserScript(
            source: "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(cssScript)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        
        // Use the app's background color to prevent skeleton mismatch
        let uiColor = UIColor(backgroundColor)
        webView.backgroundColor = uiColor
        webView.scrollView.backgroundColor = uiColor
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        
        // Load the URL
        let request = URLRequest(url: url)
        webView.load(request)
        
        debugPrint("[WebView] Loading URL: \(url)")
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        private var hasCompletedOnboarding = false
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            debugPrint("[WebView] Page loaded successfully")
            
            // Check if the JavaScript bridge is available
            let checkBridgeJS = """
            (function() {
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.flutter_bridge) {
                    return 'Bridge available';
                } else {
                    return 'Bridge NOT available - handlers: ' + Object.keys(window.webkit?.messageHandlers || {}).join(', ');
                }
            })();
            """
            
            webView.evaluateJavaScript(checkBridgeJS) { result, error in
                if let error = error {
                    debugPrint("[WebView] Error checking bridge: \(error)")
                } else if let result = result {
                    debugPrint("[WebView] Bridge check result: \(result)")
                }
            }
            
            // Wait for initial_load_complete from the web content
            // The web content will send this when it's ready to be shown
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            debugPrint("[WebView] Navigation failed: \(error)")
            parent.showFallback = true
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            debugPrint("[WebView] Provisional navigation failed: \(error)")
            parent.showFallback = true
        }
        
        // MARK: - WKScriptMessageHandler
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            debugPrint("[WebView] Received message on channel '\(message.name)': \(message.body)")
            
            guard message.name == JSMessageHandler.onboardingChannel else { 
                debugPrint("[WebView] Ignoring message from unknown channel: \(message.name)")
                return 
            }
            
            // Handle simple string messages
            guard let messageString = message.body as? String else {
                debugPrint("[WebView] Invalid message format - expected string, got: \(type(of: message.body))")
                return
            }
            
            // Parse message based on string format
            if messageString.starts(with: "themeStyle:") {
                let style = String(messageString.dropFirst("themeStyle:".count))
                handleStatusBarUpdate(style: style)
            } else if messageString.starts(with: "form_responses:") {
                let jsonStr = String(messageString.dropFirst("form_responses:".count))
                handleFormResponses(jsonStr: jsonStr)
            } else if messageString == "close_pressed" {
                handleComplete()
            } else if messageString == "request_rating" {
                handleAppReviewRequest()
            } else if messageString.starts(with: "request_permission:") {
                let permission = String(messageString.dropFirst("request_permission:".count))
                handlePermissionRequest(permission: permission)
            } else if messageString == "initial_load_complete" {
                debugPrint("[WebView] Received initial_load_complete signal from JS")
                parent.isInitialLoadComplete = true
            } else {
                debugPrint("[WebView] Unknown message: \(messageString)")
            }
        }
        
        private func handleFormResponses(jsonStr: String) {
            debugPrint("[WebView] Received form_responses JSON")
            
            guard let jsonData = jsonStr.data(using: .utf8) else {
                debugPrint("[WebView] Error: Could not convert JSON string to data")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(OnboardingResult.self, from: jsonData)
                parent.formResponses = result
                debugPrint("[WebView] Received \(result.responseCount) form responses from web")
                
                // Log each response for debugging
                for response in result.responses {
                    debugPrint("[WebView] Response: \"\(response.questionText)\" => \(response.answer)")
                }
            } catch {
                debugPrint("[WebView] Error parsing form responses: \(error)")
                debugPrint("[WebView] Raw JSON: \(jsonStr)")
            }
        }
        
        private func handleComplete() {
            guard !hasCompletedOnboarding else { return }
            hasCompletedOnboarding = true
            
            debugPrint("[WebView] Onboarding completed with \(parent.formResponses?.responseCount ?? 0) responses")
            
            // Save completion status if not in testing mode
            if !parent.testingEnabled {
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.onboardingCompleted)
            }
            
            // Call completion callback with form responses
            parent.onComplete?(parent.formResponses)
        }
        
        private func handlePermissionRequest(permission: String) {
            debugPrint("[WebView] Permission requested: \(permission)")
            
            PermissionsHandler.requestPermission(type: permission) { granted in
                debugPrint("[WebView] Permission \(permission) granted: \(granted)")
            }
        }
        
        private func handleAppReviewRequest() {
            debugPrint("[WebView] App review requested")
            
            Task { @MainActor in
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
            }
        }
        
        private func handleStatusBarUpdate(style: String) {
            debugPrint("[WebView] Status bar update: \(style)")
            
            let needsLightContent = (style == "light" || style == "dark")
            StatusBarHelper.updateStatusBar(needsLightContent: needsLightContent)
        }
    }
}

/// Main view that hosts the WebView with loading and fallback states
struct WebViewScreen: View {
    let initialURL: String
    let testingEnabled: Bool
    let appName: String
    let backgroundColor: Color
    let onComplete: OnboardingCompleteCallback?
    
    @State private var isInitialLoadComplete = false
    @State private var showFallback = false
    @State private var formResponses: OnboardingResult?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea(.all, edges: .all)
            
            if showFallback {
                FallbackView(
                    appName: appName,
                    backgroundColor: backgroundColor,
                    onComplete: { _ in
                        debugPrint("[WebViewScreen] Fallback screen continue pressed after error")
                        dismiss()
                    }
                )
            } else {
                ZStack {
                    // WebView (always present but hidden until ready)
                    if let url = URL(string: initialURL) {
                        WebView(
                            url: url,
                            testingEnabled: testingEnabled,
                            isInitialLoadComplete: $isInitialLoadComplete,
                            showFallback: $showFallback,
                            formResponses: $formResponses,
                            onComplete: { result in
                                onComplete?(result)
                                // Small delay to ensure style restoration happens before dismiss animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    dismiss()
                                }
                            },
                            backgroundColor: backgroundColor
                        )
                        .ignoresSafeArea(.all, edges: .all)
                        .opacity(isInitialLoadComplete ? 1 : 0)
                    }
                    
                    // Loading screen (shown until initial load completes)
                    if !isInitialLoadComplete {
                        LoadingView(
                            appName: appName,
                            backgroundColor: backgroundColor
                        )
                    }
                }
            }
        }
        .onAppear {
            // Set initial status bar style based on background color
            setStatusBarForBackgroundColor(backgroundColor)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func setStatusBarForBackgroundColor(_ color: Color) {
        let needsLightContent = ColorUtils.isDarkColor(color)
        StatusBarHelper.updateStatusBar(needsLightContent: needsLightContent)
    }
}