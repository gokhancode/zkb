# Testing ZüriBudget

Complete guide to testing the ZüriBudget iOS app.

## Prerequisites

- **Xcode 15.0+** (required for Swift 6 and SwiftData)
- **macOS Ventura or later**
- **iOS 17.0+ device or simulator**

## Setup Instructions

### 1. Create Xcode Project

Since we've built the code structure, you need to create an Xcode project:

**Option A: Using Xcode (Recommended)**

1. Open Xcode
2. File → New → Project
3. Select "iOS" → "App"
4. Configure:
   - **Product Name**: `ZuriBudget`
   - **Organization Identifier**: `com.yourname`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData
5. Save to the `zkb/ZuriBudget` directory

**Option B: Using Command Line**

```bash
cd /home/user/zkb
# Xcode project file will be created when you open Xcode
```

### 2. Add Files to Xcode

1. In Xcode, right-click on the `ZuriBudget` group
2. Select "Add Files to ZuriBudget..."
3. Add all folders:
   - `Models/`
   - `Services/`
   - `Views/`
   - `ViewModels/`
   - `Design/`
4. Ensure "Copy items if needed" is **unchecked**
5. Ensure "Create groups" is selected

### 3. Configure Info.plist

Add required permissions:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock ZüriBudget to access your financial data</string>

<key>UISupportsDocumentBrowser</key>
<true/>
```

### 4. Build Configuration

- **Minimum Deployment Target**: iOS 17.0
- **Swift Language Version**: Swift 6

## Running the App

### On iOS Simulator

1. In Xcode, select a simulator (iPhone 15 Pro recommended)
2. Press `Cmd + R` or click the "Play" button
3. Wait for build to complete

**Note**: Biometric authentication won't work in simulator. The app will fall back to passcode.

### On Physical Device

1. Connect your iPhone via USB
2. Select your device in Xcode
3. **Important**: Sign the app with your Apple Developer account
   - Go to Project Settings → Signing & Capabilities
   - Select your Team
4. Press `Cmd + R` to build and run
5. On first launch, trust the developer certificate on your iPhone
   - Settings → General → VPN & Device Management

## Testing Features

### 1. Authentication (Face ID/Touch ID)

**First Launch:**
- App will prompt for biometric authentication
- On simulator: Click "Cancel" → Falls back to passcode
- On device: Use Face ID or Touch ID

**Background/Foreground:**
- Send app to background (swipe up)
- Return to app
- Authentication required again ✅

**Disable Authentication (for testing):**
```swift
// In UserDefaults (temporary)
UserDefaults.standard.requireAuthOnLaunch = false
```

### 2. Dashboard (HomeView)

**Empty State:**
- On first launch, should show "No Transactions Yet"
- See "Import Statement" button ✅

**With Data:**
- After importing PDF, should show:
  - Balance header (large, bold)
  - Income/Expense summary cards
  - Recent 5 transactions ✅

### 3. PDF Import

Since you might not have a real ZKB statement, create a **sample PDF**:

#### Create Sample PDF

**Option A: Use the provided generator**

Create a file `generate_sample_zkb.py`:

```python
#!/usr/bin/env python3
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from datetime import datetime, timedelta

def create_zkb_statement():
    filename = "ZKB_Sample_Statement.pdf"
    c = canvas.Canvas(filename, pagesize=A4)
    width, height = A4

    # Header
    c.setFont("Helvetica-Bold", 16)
    c.drawString(50, height - 50, "Zürcher Kantonalbank")

    c.setFont("Helvetica", 12)
    c.drawString(50, height - 80, "Kontoauszug Januar 2026")
    c.drawString(50, height - 100, "IBAN: CH93 0070 0110 0012 3456 7")

    # Transactions
    y = height - 150
    c.setFont("Helvetica", 10)

    transactions = [
        ("15.01.2026", "Lohnzahlung Januar 2026", "-7500.00"),
        ("14.01.2026", "COOP Zürich, Kaufvertrag", "45.80"),
        ("14.01.2026", "SBB Billett Zürich HB", "12.40"),
        ("13.01.2026", "Migros Basel, Einkauf", "67.35"),
        ("12.01.2026", "Swisscom AG Rechnung", "89.00"),
        ("11.01.2026", "Denner Zürich", "23.50"),
        ("10.01.2026", "VBZ Monatskarte", "89.00"),
        ("09.01.2026", "Restaurant Kronenhalle", "125.80"),
        ("08.01.2026", "CSS Krankenkasse Prämie", "456.00"),
        ("07.01.2026", "Manor Zürich", "87.90"),
    ]

    for date, description, amount in transactions:
        c.drawString(50, y, f"{date} {description}")
        c.drawRightString(width - 50, y, f"CHF {amount}")
        y -= 20

    # Footer
    c.drawString(50, 50, f"Saldo: CHF 6'234.56")

    c.save()
    print(f"Created {filename}")

if __name__ == "__main__":
    create_zkb_statement()
```

**Install dependencies and run:**
```bash
pip3 install reportlab
python3 generate_sample_zkb.py
```

**Option B: Manual Text PDF**

Create a text file `sample.txt`:

```
Zürcher Kantonalbank
Kontoauszug Januar 2026

15.01.2026 Lohnzahlung Januar 2026 -7500.00
14.01.2026 COOP Zürich, Kaufvertrag CHF 45.80
14.01.2026 SBB Billett Zürich HB CHF 12.40
13.01.2026 Migros Basel, Einkauf CHF 67.35
12.01.2026 Swisscom AG Rechnung CHF 89.00

Saldo: CHF 6'234.56
```

Then convert to PDF:
- macOS: Open in TextEdit → File → Export as PDF
- Online: Use any text-to-PDF converter

#### Test Import Flow

1. **Trigger Import**: Tap "+" button or "Import Statement"
2. **Select PDF**: Choose your sample PDF
3. **Watch Loading**: Spinner appears "Parsing PDF..." ✅
4. **Dry-Run View**: Should show:
   - Success icon
   - File name
   - Transaction count (e.g., "10 transactions found")
   - Credits count (1 - the salary)
   - Debits count (9 - the expenses)
   - Full list of parsed transactions ✅
5. **Confirm Import**: Tap "Import X Transactions"
6. **Dashboard Updates**: Balance, income, expenses updated ✅
7. **PDF Deleted**: Original PDF is gone (check with file manager)

### 4. Transaction List

**Access**: Tap "See All" or menu → "All Transactions"

**Test Search:**
- Type "COOP" → Should show only COOP transactions ✅
- Type "Migros" → Should show only Migros ✅

**Test Category Filter:**
- Tap "Category" → Select "Groceries"
- Should show only Coop, Migros, Denner ✅

**Test Type Filter:**
- Tap "Type" → Select "Credit"
- Should show only salary ✅
- Select "Debit" → Shows all expenses ✅

**Test Deletion:**
- Long-press on transaction → "Delete"
- Confirm → Transaction removed ✅

### 5. Security Features

**File Size Limit:**
- Try to import a PDF > 10 MB
- Should see error: "File too large" ✅

**Invalid Format:**
- Try to import a non-ZKB PDF
- Should see: "PDF does not appear to be a ZKB statement" ✅

**Data Protection:**
1. Lock your device (on physical device)
2. Data should be encrypted ✅
3. Unlock → Data accessible again

**Background Security:**
1. Send app to background
2. Open app switcher
3. App content should be hidden/blurred (iOS default) ✅

## Common Issues

### Issue 1: Build Errors

**Problem**: "Cannot find 'Transaction' in scope"

**Solution**: Ensure all files are added to the Xcode target
- Select each `.swift` file
- Check "Target Membership" in File Inspector
- Ensure "ZuriBudget" is checked

### Issue 2: SwiftData Errors

**Problem**: "Could not create ModelContainer"

**Solution**: Clean build folder
- Product → Clean Build Folder (`Cmd + Shift + K`)
- Rebuild (`Cmd + B`)

### Issue 3: Biometric Auth Not Working

**Problem**: "Biometric authentication failed"

**Solution (Simulator)**:
- This is expected. Simulator doesn't support biometrics.
- App will fall back to passcode automatically.

**Solution (Device)**:
- Ensure Face ID/Touch ID is set up in Settings
- Grant permission when prompted

### Issue 4: PDF Not Parsing

**Problem**: "No transactions found"

**Solution**: Check PDF format
- PDF must contain text (not scanned image)
- Must have "Zürcher Kantonalbank" or "ZKB" or "Kontoauszug"
- Transactions must have date format: dd.mm.yyyy

## Testing Checklist

Use this checklist for comprehensive testing:

### Authentication
- [ ] Face ID/Touch ID works on launch
- [ ] Passcode fallback works
- [ ] Re-auth required after backgrounding

### Dashboard
- [ ] Shows "No Transactions" on first launch
- [ ] Balance displayed correctly
- [ ] Income/Expense cards show correct totals
- [ ] Recent 5 transactions displayed

### PDF Import
- [ ] File picker opens
- [ ] Can select PDF
- [ ] Loading spinner shows during parsing
- [ ] Dry-run view displays correctly
- [ ] Statistics (transactions, credits, debits) correct
- [ ] Can confirm import
- [ ] Can cancel import
- [ ] PDF deleted after import

### Transaction Management
- [ ] All transactions list loads
- [ ] Search works
- [ ] Category filter works
- [ ] Type filter works
- [ ] Clear filters works
- [ ] Delete transaction works
- [ ] Empty state shows when no results

### Security
- [ ] File size limit enforced (10 MB)
- [ ] Invalid PDFs rejected
- [ ] Data encrypted when device locked
- [ ] App locks on background

### Swiss Design
- [ ] All text uses San Francisco font
- [ ] Spacing follows 8pt grid
- [ ] Colors match ZKB brand (blue #0066B2)
- [ ] Minimal corner radius (6px)
- [ ] No drop shadows (except FAB)

## Performance Testing

### Memory Usage

Monitor in Xcode:
1. Debug → Memory Graph
2. Import large PDF (close to 10 MB)
3. Check for memory leaks ✅

### PDF Parsing Speed

Expected times:
- Small PDF (1-2 pages): < 1 second
- Medium PDF (10-20 pages): 1-3 seconds
- Large PDF (50-100 pages): 3-10 seconds

### Database Performance

1. Import 100+ transactions
2. Search should still be instant
3. Scrolling should be smooth (60fps)

## Accessibility Testing

### VoiceOver

1. Enable VoiceOver: Settings → Accessibility → VoiceOver
2. Navigate through app
3. All buttons should have labels ✅
4. All amounts should be spoken correctly ✅

### Dynamic Type

1. Settings → Accessibility → Display & Text Size
2. Increase text size
3. App should scale appropriately ✅

### Dark Mode

1. Control Center → Toggle Dark Mode
2. Colors should adapt ✅
3. Contrast should remain high ✅

## Debugging

### Enable Verbose Logging

Add to `PDFParserService`:
```swift
print("📄 Parsing PDF: \(fileName)")
print("📊 Found \(transactions.count) transactions")
```

### View SwiftData Database

In Xcode debugger:
```swift
po transactions
```

### Inspect File Protection

```swift
print(DataProtectionManager.shared.dataProtectionStatus())
```

## Submitting Feedback

If you find issues:

1. Check console logs in Xcode
2. Take screenshots
3. Note iOS version and device model
4. Report at: https://github.com/gokhancode/zkb/issues

---

**Happy Testing! 🇨🇭**

For questions about features, see README.md
For privacy details, see PRIVACY_POLICY.md
