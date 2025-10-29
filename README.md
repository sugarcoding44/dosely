# Dosely iOS App

**Dosely** is a native iOS application for tracking GLP-1 medications, weight progress, and health data with Apple Health integration.

## Features

✨ **Core Features:**
- 🔐 Secure authentication with Supabase
- 💊 Medication tracking with dose schedules
- ⚖️ Weight logging and progress charts
- 📊 Visual dashboard with statistics
- 🍎 Apple Health (HealthKit) integration
- 🔔 Local push notifications for medication reminders
- 📴 Offline mode with data sync
- 🌙 Dark mode support

## Requirements

- **Xcode 15.0+**
- **iOS 17.0+**
- **Swift 5.9+**
- **Mac with Apple Silicon or Intel**
- **Apple Developer Account** (for device testing and App Store submission)

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **Supabase Swift SDK** - Backend & authentication
- **HealthKit** - Apple Health integration
- **UserNotifications** - Local push notifications
- **Swift Charts** - Data visualization
- **Core Data** - Offline storage (coming soon)

## Quick Start

### 1. Open the Project in Xcode

```bash
cd Dosely-iOS
open Dosely.xcodeproj
```

If you don't have an Xcode project file yet, follow the "Creating the Xcode Project" section below.

### 2. Install Dependencies

The app uses Swift Package Manager (SPM) for dependencies:

1. In Xcode, go to **File > Add Package Dependencies**
2. Add the Supabase Swift SDK:
   ```
   https://github.com/supabase/supabase-swift.git
   ```
3. Select version `2.0.0` or later
4. Click **Add Package**

### 3. Configure Capabilities

1. Select your project in the Project Navigator
2. Select the **Dosely** target
3. Go to **Signing & Capabilities** tab
4. Add the following capabilities:
   - **HealthKit**
   - **Push Notifications** (optional, for future features)
   - **Background Modes** - Enable "Background fetch" and "Remote notifications"

### 4. Update Bundle Identifier

1. In **Signing & Capabilities**, update the Bundle Identifier to something unique:
   ```
   com.yourcompany.dosely
   ```
2. Select your Team (requires Apple Developer account)

### 5. Build and Run

1. Select a simulator or physical device
2. Press **Cmd + R** or click the **Play** button
3. The app should build and launch!

## Creating the Xcode Project from Scratch

If you need to create a new Xcode project:

1. **Open Xcode**
2. **File > New > Project**
3. Select **iOS > App**
4. Configure:
   - **Product Name:** Dosely
   - **Interface:** SwiftUI
   - **Life Cycle:** SwiftUI App
   - **Language:** Swift
   - **Include Tests:** ✓ (optional)
5. Save to the `Dosely-iOS` directory
6. Delete the default `ContentView.swift` and `DoselyApp.swift` files
7. Add all the Swift files from this project to your Xcode project:
   - Drag the folders into Xcode's Project Navigator
   - Make sure "Copy items if needed" is checked
   - Select "Create groups" (not folder references)

## Project Structure

```
Dosely-iOS/
├── Dosely/
│   ├── App/
│   │   ├── DoselyApp.swift          # Main app entry point
│   │   └── ContentView.swift        # Root view controller
│   ├── Models/
│   │   ├── User.swift               # User & profile models
│   │   ├── Medication.swift         # Medication model
│   │   ├── Dose.swift               # Dose tracking model
│   │   └── WeightEntry.swift        # Weight log model
│   ├── Views/
│   │   ├── Auth/                    # Login, signup, onboarding
│   │   ├── Dashboard/               # Main dashboard
│   │   ├── Medications/             # Medication management
│   │   ├── Weight/                  # Weight tracking
│   │   └── Settings/                # App settings
│   ├── Services/
│   │   ├── SupabaseService.swift    # Supabase client
│   │   ├── AuthService.swift        # Authentication manager
│   │   ├── HealthKitService.swift   # HealthKit integration
│   │   └── NotificationService.swift # Push notifications
│   └── Resources/
├── Info.plist                       # App configuration
├── Dosely.entitlements             # App capabilities
└── Package.swift                   # Swift Package dependencies
```

## Configuration

### Supabase Credentials

The app is already configured with your Supabase instance:
- URL: `https://wnjpxvzvktytrwenucbu.supabase.co`
- Anon Key: (already set in `SupabaseService.swift`)

To change these, edit `Services/SupabaseService.swift`:
```swift
private let supabaseURL = "YOUR_SUPABASE_URL"
private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

### HealthKit Permissions

The app requests these HealthKit permissions:
- **Read:** Body Mass (weight data)
- **Write:** Body Mass (save weight to Health app)

These are configured in `Info.plist`:
- `NSHealthShareUsageDescription`
- `NSHealthUpdateUsageDescription`

## Testing

### On Simulator
- Most features work on simulator
- **HealthKit is NOT available on simulator** - test on a real device

### On Physical Device
1. Connect your iPhone via USB
2. Select your device in Xcode's device menu
3. Click Run (Cmd + R)
4. Trust the developer certificate on your iPhone (Settings > General > VPN & Device Management)

## Building for App Store

### 1. Prepare App Store Assets
- App icon (1024x1024px)
- Screenshots for all device sizes
- App description, keywords, category
- Privacy policy URL

### 2. Archive the App
1. In Xcode, select **Any iOS Device** (not a simulator)
2. Go to **Product > Archive**
3. Wait for the build to complete
4. Click **Distribute App**
5. Follow the wizard to submit to App Store Connect

### 3. App Store Connect
1. Create your app at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Fill in all metadata
3. Upload your build
4. Submit for review

## Features Roadmap

### ✅ Completed
- Authentication (login, signup, password reset)
- Medication tracking
- Dose logging
- Weight tracking with charts
- HealthKit integration
- Push notifications
- Onboarding flow
- Settings & profile management

### 🚧 Coming Soon
- Core Data for offline mode
- Background sync
- Widget support
- Apple Watch app
- Medication reminders (time-based)
- Symptom tracking enhancements
- Export data to CSV/PDF
- Sharing progress with healthcare provider

## Troubleshooting

### Build Errors

**"Cannot find 'Supabase' in scope"**
- Make sure you've added the Supabase Swift package
- Go to File > Add Package Dependencies
- Add `https://github.com/supabase/supabase-swift.git`

**HealthKit not working**
- HealthKit only works on real devices, not simulators
- Make sure HealthKit capability is enabled
- Check that your device has Health app set up

**"Code signing" error**
- You need an Apple Developer account to run on real devices
- Free accounts work for personal use
- Update Bundle Identifier to be unique

### Runtime Issues

**Login fails**
- Check Supabase console for user accounts
- Verify Supabase URL and keys are correct
- Check network connectivity

**HealthKit permission denied**
- The user needs to grant permission in Settings
- Go to Settings > Privacy & Security > Health > Dosely

## Support

For issues or questions:
1. Check this README
2. Review the code comments
3. Check Supabase logs at [supabase.com](https://supabase.com)

## License

Private project - All rights reserved

---

**Made with ❤️ for iOS**
