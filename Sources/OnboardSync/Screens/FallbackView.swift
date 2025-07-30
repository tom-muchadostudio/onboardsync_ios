//
//  FallbackView.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import SwiftUI

/// Fallback screen shown when onboarding cannot be loaded
struct FallbackView: View {
    let appName: String
    let backgroundColor: Color
    let onComplete: OnboardingCompleteCallback?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    Text("👋")
                        .font(.system(size: 60))
                    
                    VStack(spacing: 16) {
                        Text("Welcome to \(appName)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                        
                        Text("We're excited to have you on board!")
                            .font(.system(size: 18))
                            .foregroundColor(secondaryTextColor)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Button(action: continueButtonTapped) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(buttonTextColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(buttonBackgroundColor)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            debugPrint("[FallbackScreen] Showing fallback screen")
        }
    }
    
    private var textColor: Color {
        ColorUtils.isDarkColor(backgroundColor) ? .white : .black
    }
    
    private var secondaryTextColor: Color {
        ColorUtils.isDarkColor(backgroundColor) ? Color(white: 0.7) : Color(UIColor.darkGray)
    }
    
    private var buttonBackgroundColor: Color {
        ColorUtils.isDarkColor(backgroundColor) ? .white : .black
    }
    
    private var buttonTextColor: Color {
        ColorUtils.isDarkColor(backgroundColor) ? .black : .white
    }
    
    private func continueButtonTapped() {
        debugPrint("[FallbackScreen] Continue button tapped")
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.onboardingCompleted)
        
        // Call completion callback
        onComplete?()
        
        // Dismiss
        dismiss()
    }
}

#Preview {
    FallbackView(appName: "Test App", backgroundColor: .white, onComplete: nil)
}