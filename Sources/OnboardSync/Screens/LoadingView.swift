//
//  LoadingView.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import SwiftUI

/// Loading screen displayed while the onboarding WebView is initializing
struct LoadingView: View {
    let appName: String
    let backgroundColor: Color
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .tint(textColor)
                
                VStack(spacing: 12) {
                    Text("Welcome")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(textColor)
                    
                    Text("We are just setting up your onboarding.")
                        .font(.system(size: 16))
                        .foregroundColor(secondaryTextColor)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            .onAppear {
                debugPrint("[LoadingScreen] Showing initial loading screen")
            }
        }
    }
    
    private var textColor: Color {
        ColorUtils.isDarkColor(backgroundColor) ? .white : .black
    }
    
    private var secondaryTextColor: Color {
        ColorUtils.isDarkColor(backgroundColor) ? Color.white.opacity(0.7) : Color.black.opacity(0.6)
    }
}

#Preview {
    LoadingView(appName: "Test App", backgroundColor: .white)
}