# onboardsync_swift

A SwiftUI-based SDK for integrating [OnboardSync](https://onboardsync.com) - a remote configuration platform for mobile app onboarding flows with A/B testing capabilities.

## Features

- 🚀 **Simple Integration** - Just one method call to show onboarding
- 🎨 **Remote Configuration** - Update onboarding flows without app updates
- 📊 **A/B Testing** - Test different onboarding experiences
- 🔄 **Automatic Fallback** - Graceful handling when offline
- 📱 **SwiftUI Native** - Built with modern SwiftUI for optimal performance
- 🎯 **Smart Targeting** - Show onboarding only to new users
- 🔔 **Permission Handling** - Built-in support for system permissions
- ⭐ **App Reviews** - Integrated app rating requests

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the onboardsync_swift SDK to your project using Swift Package Manager:

1. In Xcode, select **File > Add Package Dependencies**
2. Add the package URL or local path
3. Select the latest version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(name: "onboardsync_swift", path: "../path/to/onboardsync_ios_package")
]
```

## Quick Start

1. **Import the SDK**

```swift
import onboardsync_swift
```

2. **Show onboarding in your app**

```swift
// From any SwiftUI view or UIKit view controller
let config = OnboardSyncConfig(
    projectId: "[project_key]",
    secretKey: "[secret_key]"
)

OnboardSync.showOnboarding(config: config)
```

That's it! The SDK handles everything else automatically.

## Complete Example - SwiftUI

```swift
import SwiftUI
import OnboardSync

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to My App")
                .font(.largeTitle)
            
            Button("Start Onboarding") {
                showOnboarding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func showOnboarding() {
        let config = OnboardSyncConfig(
            projectId: "your-project-id",
            secretKey: "your-secret-key",
            testingEnabled: false, // Set to true during development
            onComplete: { result in
                // Called when onboarding completes
                print("Onboarding completed!")
                
                // Access form responses if available
                if let result = result {
                    for response in result.responses {
                        print("\(response.questionText): \(response.answerAsString ?? "")")
                    }
                }
            }
        )
        
        OnboardSync.showOnboarding(config: config)
    }
}
```

## Complete Example - UIKit

```swift
import UIKit
import OnboardSync

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show onboarding when view appears
        showOnboarding()
    }
    
    func showOnboarding() {
        let config = OnboardSyncConfig(
            projectId: "your-project-id",
            secretKey: "your-secret-key",
            testingEnabled: false, // Set to true during development
            onComplete: { [weak self] result in
                // Called when onboarding completes
                print("Onboarding completed!")
                
                // Access form responses if available
                if let result = result {
                    for response in result.responses {
                        print("\(response.questionText): \(response.answerAsString ?? "")")
                    }
                }
                
                self?.showMainContent()
            }
        )
        
        OnboardSync.showOnboarding(config: config)
    }
    
    func showMainContent() {
        // Navigate to your main app content
    }
}
```

## API Reference

### `OnboardSyncConfig`

Configuration object for the OnboardSync SDK.

```swift
let config = OnboardSyncConfig(
    projectId: String,      // Your OnboardSync project ID
    secretKey: String,      // Your OnboardSync secret key
    testingEnabled: Bool,   // If true, shows onboarding every time (default: false)
    onComplete: ((OnboardingResult?) -> Void)? // Optional callback with form responses
)
```

### `OnboardSync.showOnboarding()`

Displays the onboarding flow for your project.

```swift
OnboardSync.showOnboarding(
    config: OnboardSyncConfig // Your configuration
)
```

### `OnboardingResult`

Contains all form responses from a completed onboarding flow.

```swift
struct OnboardingResult {
    let flowId: String                    // The ID of the completed flow
    let responses: [OnboardingResponse]   // All form responses
    
    // Helper methods
    func getResponseByQuestion(_ questionText: String) -> OnboardingResponse?
    var textResponses: [OnboardingResponse]           // Text input responses only
    var singleChoiceResponses: [OnboardingResponse]   // Single choice responses only
    var multipleChoiceResponses: [OnboardingResponse] // Multiple choice responses only
    var hasResponses: Bool                            // Whether any responses exist
    var responseCount: Int                            // Number of responses
}
```

### `OnboardingResponse`

A single question response from the onboarding flow.

```swift
struct OnboardingResponse {
    let questionText: String    // The question that was asked
    let questionType: String    // 'question_text', 'question_single_choice', or 'question_multiple_choice'
    let answer: OnboardingAnswer // The user's answer
    let screenId: String?       // The screen ID where this question appeared
    
    // Helper properties
    var answerAsString: String? // Answer as a single string
    var answerAsList: [String]  // Answer as an array of strings
}
```

## Configuration

The SDK automatically:

- ✅ Checks if the user has completed onboarding before
- ✅ Fetches the appropriate onboarding flow based on A/B test allocation
- ✅ Displays the onboarding in a WebView
- ✅ Handles errors with a fallback screen
- ✅ Saves completion status locally
- ✅ Manages system UI (status bar) styling

## Platform Setup

### Permissions

Add required permissions to your `Info.plist`:

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for profile photos</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide personalized experiences</string>

<!-- Contacts -->
<key>NSContactsUsageDescription</key>
<string>This app needs contacts access to help you connect with friends</string>

<!-- Notifications (if needed) -->
<key>NSUserTrackingUsageDescription</key>
<string>This app needs tracking permission to provide personalized experiences</string>
```

### App Transport Security

The SDK requires internet access. Make sure your app has appropriate network permissions.

## Advanced Usage

### Testing Mode

During development, set `testingEnabled: true` to show onboarding every time:

```swift
let config = OnboardSyncConfig(
    projectId: "[project_key]",
    secretKey: "[secret_key]",
    testingEnabled: true // Always show onboarding
)
```

### Checking Onboarding Status

While the SDK automatically manages onboarding display, you can manually check the completion status:

```swift
let hasCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
```

### Resetting Onboarding

For testing purposes, you can reset the onboarding status:

```swift
UserDefaults.standard.set(false, forKey: "onboardingCompleted")
```

### Custom Completion Handling

```swift
let config = OnboardSyncConfig(
    projectId: "[project_key]",
    secretKey: "[secret_key]",
    onComplete: { result in
        // Access form responses
        if let result = result, result.hasResponses {
            // Get a specific response by question text
            if let nameResponse = result.getResponseByQuestion("What's your name?") {
                print("User name: \(nameResponse.answerAsString ?? "Unknown")")
            }
            
            // Iterate through all responses
            for response in result.responses {
                switch response.questionType {
                case "question_text":
                    print("Text answer: \(response.answerAsString ?? "")")
                case "question_single_choice":
                    print("Selected: \(response.answerAsString ?? "")")
                case "question_multiple_choice":
                    print("Selected options: \(response.answerAsList)")
                default:
                    break
                }
            }
            
            // Get responses by type
            let textResponses = result.textResponses
            let choiceResponses = result.choiceResponses
        }
        
        // Navigate to next screen, show paywall, etc.
    }
)
```

## JavaScript Bridge

The SDK communicates with your onboarding web content through a JavaScript bridge. The following messages are supported:

- `"close_pressed"` - Marks onboarding as complete and dismisses the view
- `"request_rating"` - Shows the native app store rating dialog
- `"themeStyle:light"` or `"themeStyle:dark"` - Updates the status bar style
- `"request_permission:type"` - Requests system permissions (camera, photos, location, etc.)
- `"initial_load_complete"` - Signals that the web content has loaded
- `"form_responses:{json}"` - Sends form responses as JSON to the SDK

## Error Handling

The SDK includes automatic error handling:

- Network errors show a fallback welcome screen
- Configuration errors are logged and handled gracefully
- Users can still continue using your app even if onboarding fails to load

## Debugging

Enable debug logging to see detailed SDK operations:

```swift
// Debug logs are automatically printed in DEBUG builds
// Look for logs with [OnboardSync] prefix
```

## Troubleshooting

### Onboarding not showing?

1. Check your project ID and secret key are correct
2. Ensure you have an active internet connection
3. Verify `testingEnabled` is set appropriately
4. Check debug logs for any error messages

### Permissions not working?

Make sure you've added the necessary permission descriptions to your `Info.plist` as shown above.

### App crashes on launch?

Ensure you're calling `showOnboarding` after your app has fully initialized, not during app launch.

## Example App

Check out the `/Example` folder for a complete SwiftUI example app that demonstrates:

- Basic integration
- Testing mode toggle
- Status checking
- Reset functionality

## Migration from UIKit

If you're migrating from the UIKit version of the SDK, the main change is the simplified API:

```swift
// Old UIKit way:
OnboardSync.showOnboarding(from: viewController, config: config)

// New SwiftUI way:
OnboardSync.showOnboarding(config: config)
```

The SDK now automatically finds the appropriate view controller to present from.

## Support

- 📧 Email: support@muchadostudio.com
- 🌐 Website: https://onboardsync.com
- 📚 Documentation: Visit the OnboardSync dashboard for API documentation

## License

This SDK is available under the MIT license. See the LICENSE file for more info.