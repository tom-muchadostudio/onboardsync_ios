# onboardsync_swift Example

This example demonstrates how to integrate and use the onboardsync_swift SDK in your app.

## Getting Started

1. **Configure the SDK**: Open the example app in Xcode and replace:
   - `[project_key]` with your actual OnboardSync project ID
   - `[secret_key]` with your OnboardSync secret key

2. **Configure Permissions**: The example app includes all necessary permission configurations in `Info.plist`.

3. **Run the Example**:
   - Open the `Example` folder in Xcode
   - Select your target device or simulator
   - Press Run (⌘R)

## Features Demonstrated

- **Show Onboarding**: Displays the remotely configured onboarding flow
- **Check Status**: Verifies if the user has completed onboarding
- **Reset Onboarding**: Clears the completion status for testing
- **Testing Mode**: Toggle to show onboarding every time

## Code Overview

The example app demonstrates:
- Simple integration with just a few lines of code
- Error handling and loading states
- Testing mode for development
- Status display showing the current state

## Project Structure

```
Example/
├── ContentView.swift      # SwiftUI main view with SDK integration
├── OnboardSyncExampleApp.swift  # App entry point
├── Info.plist             # App configuration and permissions
└── README.md              # This file
```

## Testing Different Flows

1. Reset the onboarding using the "Reset Onboarding" button
2. Configure different flows in your OnboardSync dashboard
3. Run the app on different devices to see A/B testing in action
4. Use Testing Mode to always show onboarding during development