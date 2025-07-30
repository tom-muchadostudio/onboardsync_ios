//
//  ContentView.swift
//  OnboardSyncExample
//
//  Created by OnboardSync on 2025-01-19.
//

import SwiftUI
// In a real app, you would import the SDK:
// import onboardsync_swift

struct ContentView: View {
    @State private var statusText = "Not started"
    @State private var isLoading = false
    @State private var testingModeEnabled = false
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("onboardsync_swift Example")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    // Status Card
                    VStack {
                        Text("Status: \(statusText)")
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Buttons
                    VStack(spacing: 16) {
                        Button(action: showOnboardingTapped) {
                            Text("Show Onboarding")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .disabled(isLoading)
                        
                        Button(action: checkStatusTapped) {
                            Text("Check Status")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                        
                        Button(action: resetOnboardingTapped) {
                            Text("Reset Onboarding")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                    }
                    
                    // Testing Mode Toggle
                    VStack {
                        Toggle("Testing Mode", isOn: $testingModeEnabled)
                            .padding()
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Instructions Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Setup Instructions:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Replace [project_key] with your actual project ID")
                            Text("2. Replace [secret_key] with your secret key")
                            Text("3. Configure your app permissions in Info.plist")
                            Text("4. Run the app and tap \"Show Onboarding\"")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text("Testing Mode: Shows onboarding every time regardless of completion status")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                        )
                }
            }
        )
    }
    
    // MARK: - Actions
    
    private func showOnboardingTapped() {
        isLoading = true
        statusText = "Loading..."
        
        // NOTE: In a real implementation, you would:
        // 1. Import the OnboardSync SDK
        // 2. Call OnboardSync.showOnboarding with your credentials
        
        /*
        let config = OnboardSyncConfig(
            projectId: "[project_key]",
            secretKey: "[secret_key]",
            testingEnabled: testingModeEnabled,
            onComplete: {
                print("[Example] Onboarding completed!")
                statusText = "Onboarding completed successfully"
            }
        )
        
        OnboardSync.showOnboarding(config: config)
        */
        
        // Simulate for demo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            statusText = "Demo mode - replace with your project credentials"
        }
    }
    
    private func checkStatusTapped() {
        // Check completion status from UserDefaults
        let hasCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        statusText = hasCompleted 
            ? "Onboarding has been completed" 
            : "Onboarding not yet completed"
    }
    
    private func resetOnboardingTapped() {
        // Clear the completion status
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
        statusText = "Onboarding reset successfully"
    }
}

#Preview {
    ContentView()
}