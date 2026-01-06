# ZüriBudget - Xcode Project Setup Guide

Complete step-by-step guide to set up the ZüriBudget iOS project in Xcode.

## Prerequisites

- **macOS Ventura (13.0) or later**
- **Xcode 15.0 or later** ([Download from Mac App Store](https://apps.apple.com/app/xcode/id497799835))
- **iOS 17.0+ device or simulator**
- **Active Apple Developer account** (free tier works for testing on physical devices)

## Step 1: Create Xcode Project

### Option A: Using Xcode GUI (Recommended)

1. **Open Xcode**
   - Launch Xcode from Applications

2. **Create New Project**
   - Click "Create a new Xcode project"
   - OR: File → New → Project (`Cmd + Shift + N`)

3. **Choose Template**
   - Select **iOS** tab
   - Choose **App** template
   - Click **Next**

4. **Configure Project**
   ```
   Product Name:              ZuriBudget
   Team:                      [Your Apple Developer Team]
   Organization Identifier:   com.yourname (e.g., com.john.apps)
   Bundle Identifier:         com.yourname.ZuriBudget
   Interface:                 SwiftUI
   Language:                  Swift
   Storage:                   SwiftData
   Include Tests:            ✅ (optional but recommended)
   ```

5. **Save Location**
   - Navigate to: `/home/user/zkb/`
   - **IMPORTANT**: Uncheck "Create Git repository" (we already have one)
   - Click **Create**

### Option B: Manual Setup

If you're experienced with Xcode:

```bash
cd /home/user/zkb
# The project structure is already created
# Just open Xcode and create a new project in the ZuriBudget directory
```

## Step 2: Add Source Files to Xcode

The code is already organized in folders. Now add them to Xcode:

### 2.1: Remove Default Files

1. In Xcode Project Navigator (left sidebar)
2. Delete these auto-generated files:
   - `ContentView.swift` (we have our own)
   - `Item.swift` (if present, we use Transaction instead)
3. Select "Move to Trash"

### 2.2: Add Project Folders

1. **Right-click** on `ZuriBudget` group (blue folder icon)
2. Select **"Add Files to ZuriBudget..."**
3. **Navigate** to `/home/user/zkb/ZuriBudget/ZuriBudget/`
4. **Select all folders**:
   - `Models/`
   - `Services/`
   - `Views/`
   - `ViewModels/`
   - `Design/`
5. **Configure import**:
   - ✅ **Copy items if needed**: UNCHECK (files are already in place)
   - ✅ **Create groups**: SELECT
   - ✅ **Add to targets**: Check "ZuriBudget"
6. Click **Add**

### 2.3: Replace App File

1. Delete the auto-generated `ZuriBudgetApp.swift`
2. Add our version:
   - Right-click `ZuriBudget` group
   - "Add Files to ZuriBudget..."
   - Select `ZuriBudgetApp.swift` from project root
   - **Copy items if needed**: UNCHECK
   - Click **Add**

### 2.4: Verify File Structure

Your Xcode project should now look like:

```
ZuriBudget (blue folder)
├── ZuriBudgetApp.swift
├── Models
│   ├── Transaction.swift
│   ├── TransactionType.swift
│   └── Category.swift
├── Services
│   ├── PDFParserService.swift
│   ├── BiometricAuthService.swift
│   ├── SecureFileManager.swift
│   └── DataProtectionManager.swift
├── Views
│   ├── HomeView.swift
│   ├── FinancialSummaryView.swift
│   ├── TransactionListView.swift
│   ├── TransactionRowView.swift
│   ├── DryRunView.swift
│   └── PDFImportView.swift
├── ViewModels
│   └── HomeViewModel.swift
├── Design
│   └── ZKBColors.swift
└── Assets.xcassets
```

## Step 3: Configure Build Settings

### 3.1: General Settings

1. Click on **ZuriBudget** project (blue icon) in Navigator
2. Select **ZuriBudget** target
3. Go to **General** tab

**Configure:**
```
Minimum Deployments:
  iOS: 17.0

Deployment Info:
  iPhone Orientation: Portrait
  iPad Orientation: Portrait, Landscape

```

### 3.2: Info.plist Configuration

1. **Replace Info.plist**:
   - In Project Navigator, find `Info.plist`
   - Delete it
   - Add our version from `/home/user/zkb/ZuriBudget/Info.plist`

2. **Verify Required Keys**:
   - `NSFaceIDUsageDescription`: ✅
   - `UISupportsDocumentBrowser`: ✅
   - `com.apple.developer.default-data-protection`: ✅

### 3.3: Signing & Capabilities

1. Go to **Signing & Capabilities** tab

2. **Automatic Signing**:
   - ✅ Automatically manage signing
   - Select your **Team** (Apple Developer account)

3. **Add Capabilities** (click + button):
   - **Data Protection**: Add → Complete Protection
   - This ensures encryption when device is locked

4. **Entitlements**:
   - Add our entitlements file:
     - Project Navigator → Right-click ZuriBudget
     - "Add Files to ZuriBudget..."
     - Select `ZuriBudget.entitlements`
     - Add to target: ZuriBudget

### 3.4: Build Settings

1. Go to **Build Settings** tab
2. Search for "Swift Language Version"
3. Set to: **Swift 6**

## Step 4: Verify Dependencies

All frameworks are native iOS frameworks (no CocoaPods/SPM needed):

✅ **SwiftUI** - Built-in
✅ **SwiftData** - Built-in (iOS 17+)
✅ **PDFKit** - Built-in
✅ **LocalAuthentication** - Built-in
✅ **UniformTypeIdentifiers** - Built-in

**No external dependencies required!**

## Step 5: Build the Project

### 5.1: Clean Build Folder

1. Product → Clean Build Folder (`Cmd + Shift + K`)
2. Wait for completion

### 5.2: Build

1. Product → Build (`Cmd + B`)
2. Wait for build to complete
3. ✅ **"Build Succeeded"** should appear

### 5.3: Fix Common Build Errors

**Error: "Cannot find type 'Transaction' in scope"**
- Solution: Ensure all `.swift` files are in the target
  - Select file → File Inspector → Target Membership → Check "ZuriBudget"

**Error: "Module compiled with Swift X cannot be imported by Swift Y"**
- Solution: Ensure all files use Swift 6
  - Build Settings → Swift Language Version → Swift 6

**Error: "Sandbox access violation"**
- Solution: Check entitlements file is added to target

## Step 6: Run on Simulator

1. **Select Simulator**:
   - Top toolbar → Select "iPhone 15 Pro" (or newer)

2. **Run** (`Cmd + R`):
   - Click Play button OR
   - Product → Run

3. **First Launch**:
   - App opens with lock screen
   - **Note**: Simulator doesn't support Face ID
   - Click "Cancel" → Falls back to passcode
   - Click "Authenticate" again → Should unlock

4. **Test Features**:
   - ✅ Dashboard appears
   - ✅ Shows "No Transactions Yet"
   - ✅ "Import Statement" button visible

## Step 7: Run on Physical Device

### 7.1: Connect Device

1. Connect iPhone via Lightning/USB-C cable
2. Unlock your iPhone
3. Trust computer if prompted

### 7.2: Select Device

1. Top toolbar → Select your iPhone
2. Ensure it says "iPhone (Your Name's iPhone)"

### 7.3: Code Signing

**Free Apple Developer Account:**
- Xcode may show "Failed to create provisioning profile"
- Solution:
  1. Xcode → Preferences → Accounts
  2. Add your Apple ID
  3. Select your account → Download Manual Profiles
  4. Return to project → Signing should work

### 7.4: Trust Developer Certificate

First time running on device:

1. Install app on iPhone (may take a few minutes)
2. On iPhone: Settings → General → VPN & Device Management
3. Find your developer certificate
4. Tap "Trust [Your Name]"
5. Confirm trust

### 7.5: Run App

1. Return to Xcode
2. Press `Cmd + R`
3. App should launch on your iPhone
4. Face ID prompt appears → Authenticate ✅

## Step 8: Generate Sample PDF for Testing

### 8.1: Install Python Dependencies

```bash
pip3 install reportlab
```

### 8.2: Generate PDF

```bash
cd /home/user/zkb
python3 generate_sample_zkb_statement.py
```

This creates `ZKB_Sample_Statement_January_2026.pdf`

### 8.3: Transfer PDF to Device/Simulator

**For Simulator:**
1. Drag PDF file onto simulator window
2. Safari opens → Click "Download" icon
3. PDF saved to Files app

**For Physical Device:**
1. AirDrop PDF to iPhone, OR
2. Email PDF to yourself, OR
3. Add to iCloud Drive on Mac → Access from iPhone Files app

### 8.4: Import PDF in App

1. Open ZüriBudget app
2. Tap **+** button (floating action button)
3. Tap **"Choose PDF"**
4. Navigate to PDF location
5. Select PDF
6. ✅ Dry-run view should appear
7. Tap **"Import X Transactions"**
8. ✅ Dashboard updates with data

## Step 9: Testing Checklist

Run through this checklist to verify everything works:

### Authentication
- [ ] Face ID/Touch ID prompts on launch (physical device)
- [ ] Passcode fallback works
- [ ] App locks when backgrounded
- [ ] Re-authentication works when returning

### Dashboard
- [ ] Balance displays correctly
- [ ] Income/Expense cards show totals
- [ ] Recent 5 transactions visible
- [ ] Empty state shows when no data

### PDF Import
- [ ] File picker opens
- [ ] Can select PDF
- [ ] Loading indicator shows
- [ ] Dry-run preview displays
- [ ] Can confirm import
- [ ] Can cancel import
- [ ] Dashboard updates after import

### Transaction Management
- [ ] "See All" shows full list
- [ ] Search works
- [ ] Category filter works
- [ ] Type filter works
- [ ] Delete transaction works

### Security
- [ ] PDF is deleted after import
- [ ] File size limit enforced (>10MB rejected)
- [ ] Invalid PDFs rejected

### Design
- [ ] Swiss typography throughout
- [ ] Correct color palette (ZKB blue, etc.)
- [ ] Dark mode works
- [ ] Layout follows 8pt grid

## Troubleshooting

### Issue 1: Build Errors After Adding Files

**Symptom**: "Cannot find type X in scope"

**Solution**:
1. Select the file in Project Navigator
2. Show File Inspector (right sidebar)
3. Under "Target Membership"
4. ✅ Check "ZuriBudget"

### Issue 2: App Crashes on Launch

**Symptom**: App builds but crashes immediately

**Solution**:
1. Check Console output in Xcode (bottom panel)
2. Common causes:
   - SwiftData model schema mismatch
   - Missing entitlements
3. Fix: Clean build folder + rebuild

### Issue 3: Face ID Not Working

**Symptom**: Authentication always fails

**Solution (Simulator)**:
- Simulator doesn't support biometrics
- Use passcode fallback (this is expected)

**Solution (Device)**:
- Check Face ID is enabled: Settings → Face ID & Passcode
- Ensure app has permission
- Check Info.plist has NSFaceIDUsageDescription

### Issue 4: PDF Import Fails

**Symptom**: "Failed to parse PDF"

**Solution**:
1. Ensure PDF contains text (not scanned image)
2. PDF must have "ZKB" or "Zürcher Kantonalbank"
3. Use our sample PDF generator for testing

### Issue 5: Dark Mode Colors Wrong

**Symptom**: Text unreadable in dark mode

**Solution**:
- We use `.primary` and `.secondary` colors
- These adapt automatically
- If issue persists, check system dark mode is enabled

## Advanced Configuration

### Enable Debug Logging

Add to `PDFParserService.swift`:

```swift
static func parseZKBStatement(url: URL) -> ParseResult {
    print("📄 Parsing: \(url.lastPathComponent)")
    // ... rest of code
}
```

### Disable Authentication for Faster Testing

Temporarily in `ZuriBudgetApp.swift` init:

```swift
init() {
    // ... existing code ...
    #if DEBUG
    UserDefaults.standard.requireAuthOnLaunch = false
    #endif
}
```

**Remember to remove before release!**

### View SwiftData Database

In Xcode debugger (lldb):

```swift
(lldb) po transactions
```

## Next Steps

After successful setup:

1. **Review Code**: Familiarize yourself with the architecture
2. **Read TESTING.md**: Comprehensive testing guide
3. **Read PRIVACY_POLICY.md**: Understand privacy guarantees
4. **Customize**: Change colors, add features, etc.

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [PDFKit Reference](https://developer.apple.com/documentation/pdfkit)
- [LocalAuthentication](https://developer.apple.com/documentation/localauthentication)

## Getting Help

If you encounter issues:

1. Check this guide first
2. Review TESTING.md
3. Check Xcode console for error messages
4. Search Apple Developer Forums
5. Open an issue on GitHub

---

**Project configured successfully? Start testing!** 🇨🇭

See TESTING.md for comprehensive testing instructions.
