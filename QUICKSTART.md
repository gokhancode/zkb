# ZüriBudget - Quick Start Guide

Get up and running with ZüriBudget in 5 minutes.

## TL;DR

```bash
# 1. Generate sample PDF
cd /home/user/zkb
pip3 install reportlab
./generate_sample_zkb_statement.py

# 2. Open Xcode, create new iOS App project in this directory
# 3. Add all ZuriBudget/ZuriBudget/* folders to project
# 4. Build and run (Cmd+R)
# 5. Import the generated PDF
# 6. ✅ Done!
```

## 5-Minute Setup

### Step 1: Prerequisites (30 seconds)

- **Xcode 15+** installed? [Get it from Mac App Store](https://apps.apple.com/app/xcode/id497799835)
- **iOS 17+ device or simulator**

### Step 2: Create Xcode Project (2 minutes)

1. Open Xcode
2. File → New → Project
3. Select **iOS > App**
4. Configure:
   ```
   Product Name: ZuriBudget
   Interface: SwiftUI
   Language: Swift
   Storage: SwiftData
   ```
5. Save to `/home/user/zkb/ZuriBudget`
6. ✅ **Uncheck** "Create Git repository"

### Step 3: Add Source Files (1 minute)

1. Delete auto-generated `ContentView.swift` and `ZuriBudgetApp.swift`
2. Right-click `ZuriBudget` group → "Add Files to ZuriBudget..."
3. Select all folders:
   - `Models/`
   - `Services/`
   - `Views/`
   - `ViewModels/`
   - `Design/`
   - `ZuriBudgetApp.swift`
4. **Uncheck** "Copy items if needed"
5. Click **Add**

### Step 4: Configure Project (1 minute)

1. Replace `Info.plist` with ours: `ZuriBudget/Info.plist`
2. Add entitlements: `ZuriBudget/ZuriBudget.entitlements`
3. Set **Minimum Deployment**: iOS 17.0
4. Select your **Team** in Signing & Capabilities

### Step 5: Build and Run (30 seconds)

1. Select iPhone simulator or device
2. Press `Cmd + R`
3. ✅ App launches with lock screen
4. Cancel Face ID (simulator) → Authenticate

### Step 6: Generate Test PDF (30 seconds)

```bash
cd /home/user/zkb
pip3 install reportlab
./generate_sample_zkb_statement.py
```

This creates `ZKB_Sample_Statement_January_2026.pdf`

### Step 7: Import PDF in App (30 seconds)

**On Simulator:**
1. Drag PDF onto simulator
2. Safari opens → Save to Files
3. In ZüriBudget app: Tap **+**
4. Choose PDF
5. ✅ Preview shows → Tap "Import"

**On Device:**
1. AirDrop PDF to iPhone
2. In ZüriBudget app: Tap **+**
3. Choose PDF from Files
4. ✅ Preview shows → Tap "Import"

## What You Get

After import, you'll see:

- **Balance**: CHF 4'123.45 (or similar)
- **Income**: CHF 7'500.00 (salary)
- **Expenses**: ~CHF 3'376.55
- **32 transactions** across 13 categories

## Test These Features

### Dashboard
- ✅ View balance, income, expenses
- ✅ See recent 5 transactions
- ✅ Tap "See All" for full list

### Search & Filter
- ✅ Search "COOP" → Shows only COOP
- ✅ Filter by "Groceries" category
- ✅ Filter by "Debit" type

### Security
- ✅ App locks when backgrounded
- ✅ Re-authentication required
- ✅ PDF auto-deleted after import

### Swiss Design
- ✅ ZKB blue color (#0066B2)
- ✅ Clean typography
- ✅ 8pt grid alignment
- ✅ Dark mode support

## Common Issues

**Build Error: "Cannot find Transaction"**
- Solution: Ensure all files added to target (File Inspector → Target Membership)

**Face ID Not Working (Simulator)**
- This is normal. Simulator doesn't support Face ID.
- Click "Cancel" → Falls back to passcode

**PDF Not Parsing**
- Ensure PDF contains "ZKB" or "Zürcher Kantonalbank"
- Use our generated PDF for testing

## Need More Help?

- **Detailed setup**: See [SETUP.md](SETUP.md)
- **Testing guide**: See [TESTING.md](TESTING.md)
- **Privacy info**: See [PRIVACY_POLICY.md](PRIVACY_POLICY.md)
- **Code overview**: See [README.md](README.md)

## Next Steps

Once everything works:

1. **Explore the code** - Learn the architecture
2. **Customize** - Change colors, add features
3. **Test on device** - Try Face ID authentication
4. **Add real data** - Import your actual ZKB statement

---

**Got it working? You're ready to track your finances! 🇨🇭**
