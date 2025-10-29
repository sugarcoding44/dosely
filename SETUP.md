# Dosely iOS - Detailed Setup Guide

Complete step-by-step instructions for setting up the Dosely iOS app.

## Prerequisites

Before you begin, ensure you have:

- ✅ **Mac computer** (MacBook, iMac, Mac Mini, or Mac Pro)
- ✅ **macOS Sonoma 14.0 or later**
- ✅ **Xcode 15.0 or later** (download from Mac App Store)
- ✅ **Apple ID** (free, create at [appleid.apple.com](https://appleid.apple.com))
- ✅ **Apple Developer Account** (optional, but needed for device testing)

## Part 1: Create Xcode Project

Since you have all the Swift files ready, here's how to create the Xcode project:

### Step 1: Open Xcode

1. Open **Xcode** from Applications
2. If this is first launch, agree to license terms
3. Wait for Xcode to install components

### Step 2: Create New Project

1. Click **Create New Project** (or File > New > Project)
2. Select **iOS** tab at the top
3. Choose **App** template
4. Click **Next**

### Step 3: Configure Project

Fill in these settings:

- **Product Name:** `Dosely`
- **Team:** Select your Apple ID (sign in if needed)
- **Organization Identifier:** `com.yourname` (use your name)
- **Bundle Identifier:** Will auto-generate as `com.yourname.Dosely`
- **Interface:** **SwiftUI** ⚠️ Important!
- **Language:** **Swift** ⚠️ Important!
- **Storage:** Leave as default
- **Include Tests:** ✓ (optional, but recommended)

Click **Next**, then choose `C:\Users\user\Dosely-iOS` as the save location.

### Step 4: Initial Project Structure

Xcode will create:
```
Dosely/
├── DoselyApp.swift
├── ContentView.swift
└── Assets.xcassets/
```

**Delete the default files:**
1. Right-click `DoselyApp.swift` and `ContentView.swift`
2. Select **Delete** > **Move to Trash**

### Step 5: Add Your Swift Files

Now add all the Swift files from this project:

1. In **Finder**, open `C:\Users\user\Dosely-iOS\Dosely`
2. In **Xcode Project Navigator** (left sidebar), right-click **Dosely**
3. Select **Add Files to "Dosely"...**
4. Navigate to your Dosely folder
5. Select these folders (hold Cmd to select multiple):
   - **App**
   - **Models**
   - **Views**
   - **Services**
6. Make sure these options are checked:
   - ✅ **Copy items if needed**
   - ✅ **Create groups** (not folder references)
   - ✅ **Add to targets: Dosely**
7. Click **Add**

Your Project Navigator should now show:
```
Dosely/
├── App/
├── Models/
├── Views/
│   ├── Auth/
│   ├── Dashboard/
│   ├── Medications/
│   ├── Weight/
│   └── Settings/
├── Services/
└── Assets.xcassets/
```

## Part 2: Install Dependencies

### Add Supabase Swift SDK

1. In Xcode, go to **File > Add Package Dependencies...**
2. In the search box (top-right), paste:
   ```
   https://github.com/supabase/supabase-swift.git
   ```
3. Press **Enter**
4. Under **Dependency Rule**, select **Up to Next Major Version**
5. Version should be `2.0.0` or higher
6. Click **Add Package**
7. In the dialog, make sure **Supabase** is checked
8. Click **Add Package**
9. Wait for Xcode to download and integrate the package

You'll see "Supabase" appear under **Package Dependencies** in the Project Navigator.

## Part 3: Configure Capabilities

### Enable HealthKit

1. Select **Dosely** project (blue icon at top of Project Navigator)
2. Select **Dosely** target (under TARGETS)
3. Click **Signing & Capabilities** tab
4. Click **+ Capability** button
5. Search for **HealthKit**
6. Double-click **HealthKit** to add it
7. You should now see "HealthKit" in the capabilities list

### Enable Push Notifications (Optional)

1. Click **+ Capability** again
2. Search for **Push Notifications**
3. Double-click to add it

### Enable Background Modes (Optional)

1. Click **+ Capability** again
2. Search for **Background Modes**
3. Double-click to add it
4. Check these boxes:
   - ✅ **Background fetch**
   - ✅ **Remote notifications**

## Part 4: Configure Info.plist

### Add HealthKit Usage Descriptions

1. In Project Navigator, click **Info.plist**
2. Right-click in the list and select **Add Row**
3. Add these keys:

**Key 1:**
- **Key:** `NSHealthShareUsageDescription`
- **Type:** String
- **Value:** `Dosely needs access to your weight data to track your progress and sync with Apple Health.`

**Key 2:**
- **Key:** `NSHealthUpdateUsageDescription`
- **Type:** String
- **Value:** `Dosely would like to save your weight entries to Apple Health.`

Alternatively, you can replace the entire Info.plist with the one provided in this project.

## Part 5: Add App Icon (Optional)

1. Create or download an app icon (1024x1024px PNG)
2. In Project Navigator, click **Assets.xcassets**
3. Click **AppIcon**
4. Drag your 1024x1024 image into the "1024x1024" slot
5. Xcode will automatically generate all required sizes

For now, you can use the 💊 emoji as a placeholder (app will work without icon).

## Part 6: Build and Test

### Test on Simulator

1. At the top of Xcode, click the device menu (next to "Dosely")
2. Select **iPhone 15 Pro** (or any recent iPhone simulator)
3. Press **Cmd + R** (or click the **Play** button)
4. Wait for build to complete
5. Simulator should launch with Dosely

⚠️ **Note:** HealthKit will NOT work on simulator!

### Test on Real Device

1. Connect your iPhone via Lightning/USB-C cable
2. Unlock your iPhone
3. On iPhone, if prompted, tap **Trust This Computer**
4. In Xcode device menu, select your iPhone
5. Press **Cmd + R**

**First time only:**
- Xcode will ask to register your device
- On your iPhone, go to: **Settings > General > VPN & Device Management**
- Tap your Apple ID
- Tap **Trust "Your Name"**
- Return to Xcode and try again

### Verify Everything Works

Test these features:
1. ✅ App launches without crashing
2. ✅ You can create an account
3. ✅ You can log in
4. ✅ Onboarding flow works
5. ✅ Dashboard loads
6. ✅ You can add a medication
7. ✅ You can log weight (on device only)
8. ✅ HealthKit permission prompt appears (device only)

## Part 7: Troubleshooting

### Common Build Errors

**1. "Cannot find 'Supabase' in scope"**
```
Solution:
- File > Add Package Dependencies
- Add https://github.com/supabase/supabase-swift.git
- Make sure it's added to Dosely target
```

**2. "Code Signing Error"**
```
Solution:
- Select Dosely target
- Signing & Capabilities tab
- Select your Team (your Apple ID)
- Change Bundle Identifier to be unique:
  com.yourname.dosely
```

**3. "Swift Compiler Error"**
```
Solution:
- Make sure you're using Xcode 15+ and iOS 17+
- Product > Clean Build Folder (Cmd + Shift + K)
- Try building again (Cmd + R)
```

**4. "Missing Info.plist"**
```
Solution:
- Copy the Info.plist from this project
- Or add HealthKit usage descriptions manually
```

### Runtime Issues

**1. "Login fails"**
- Check Supabase is configured correctly
- Verify internet connection
- Check Supabase dashboard for user account

**2. "HealthKit not working"**
- HealthKit only works on real devices
- Make sure HealthKit capability is enabled
- Check iPhone has Health app set up

**3. "Notifications not working"**
- Grant notification permission when prompted
- Check Settings > Dosely > Notifications

## Part 8: Next Steps

### For Development

- **Customize colors**: Edit color values in views
- **Add features**: Modify existing views or create new ones
- **Test thoroughly**: Test on multiple devices and iOS versions

### For App Store Release

1. **Create App Store Connect Account**
   - Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Enroll in Apple Developer Program ($99/year)

2. **Prepare Assets**
   - App icon (1024x1024px)
   - Screenshots for all device sizes
   - App description, keywords

3. **Archive and Submit**
   - Product > Archive (in Xcode)
   - Follow distribution wizard
   - Submit for review

## Need Help?

If you encounter issues:

1. **Check Build Errors:** Red errors in Xcode show what's wrong
2. **Read Console:** Shows runtime errors and print statements
3. **Clean Build:** Product > Clean Build Folder (Cmd + Shift + K)
4. **Restart Xcode:** Sometimes helps with package issues
5. **Check README.md:** For general troubleshooting

## Summary Checklist

- [ ] Xcode 15+ installed
- [ ] New iOS App project created with SwiftUI
- [ ] All Swift files added to project
- [ ] Supabase Swift SDK package added
- [ ] HealthKit capability enabled
- [ ] HealthKit usage descriptions in Info.plist
- [ ] App builds successfully
- [ ] App runs on simulator
- [ ] App runs on real device (optional)
- [ ] Can create account and login
- [ ] All main features work

**Congratulations! Your Dosely iOS app is ready! 🎉**
