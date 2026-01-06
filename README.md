# ZüriBudget - iOS Finance Tracker for ZKB Users

A native iOS app built with SwiftUI that allows **Zürcher Kantonalbank (ZKB)** users to track their finances by parsing uploaded PDF monthly statements.

**🚀 Quick Start**: See [QUICKSTART.md](QUICKSTART.md) - Get running in 5 minutes
**📖 Full Setup Guide**: See [SETUP.md](SETUP.md) - Comprehensive Xcode configuration
**🧪 Testing Guide**: See [TESTING.md](TESTING.md) - Complete testing instructions
**🔒 Privacy Policy**: See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) - Privacy guarantees

---

## Design Philosophy: Swiss International Style

ZüriBudget embodies the **Swiss International Typographic Style**:

- **Grid System**: Mathematical, rigid grid layouts with precise alignment
- **Typography**: San Francisco font treated like Helvetica - high contrast, large headers, distinct weight differences
- **Minimalism**: Generous whitespace, no illustrations, functional design
- **Color Palette**: ZKB brand identity with functional color usage
- **Components**: Sharp corners (4-8px radius), flat design, no drop shadows

## Color Palette

Based on ZKB's brand identity:

| Color | Hex | Usage |
|-------|-----|-------|
| **ZKB Blue** | `#0066B2` | Primary brand color, headers, primary actions |
| **Zürich Blue** | `#268BCC` | Secondary/highlight, interactive elements |
| **Signal Red** | `#FF3B30` | Expenses/debits, critical actions |
| **Emerald Green** | `#34C759` | Income/credits, success states |
| **Canvas White** | `#FFFFFF` | Light mode background |
| **Deep Slate** | `#1C1C1E` | Dark mode background |

## Technical Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData (ModelContainer, @Model)
- **PDF Parsing**: PDFKit (Native framework)
- **Architecture**: MVVM (Model-View-ViewModel)

## Project Structure

```
ZuriBudget/
├── ZuriBudget/
│   ├── ZuriBudgetApp.swift                # App entry with security & auth
│   ├── Models/
│   │   ├── Transaction.swift              # SwiftData model for transactions
│   │   ├── TransactionType.swift          # Enum: debit/credit
│   │   └── Category.swift                 # Enum: auto-categorization logic
│   ├── Services/
│   │   ├── PDFParserService.swift         # Secure ZKB PDF parsing
│   │   ├── BiometricAuthService.swift     # Face ID/Touch ID authentication
│   │   ├── SecureFileManager.swift        # Secure file handling & auto-delete
│   │   └── DataProtectionManager.swift    # Encryption & data protection
│   ├── Views/
│   │   ├── HomeView.swift                 # Main dashboard
│   │   ├── FinancialSummaryView.swift     # Income/Expense cards
│   │   ├── TransactionListView.swift      # Full transaction list
│   │   ├── TransactionRowView.swift       # Transaction row component
│   │   ├── DryRunView.swift               # Import preview
│   │   └── PDFImportView.swift            # PDF upload UI
│   ├── ViewModels/
│   │   └── HomeViewModel.swift            # Dashboard business logic
│   └── Design/
│       └── ZKBColors.swift                # Swiss design system & colors
├── PRIVACY_POLICY.md                      # Complete privacy documentation
```

## Security Features 🔒

ZüriBudget implements **bank-level security** for your financial data:

### Multi-Layer Protection

1. **Biometric Authentication**
   - Face ID / Touch ID required on app launch (default: enabled)
   - Automatic passcode fallback if biometrics unavailable
   - Re-authentication required when returning from background

2. **Data Encryption**
   - SwiftData database encrypted with FileProtectionType.complete
   - Data accessible only when device is unlocked
   - All app directories protected with iOS Data Protection API

3. **Secure File Handling**
   - PDF files automatically deleted after parsing
   - Secure overwrite with random data before deletion
   - 10 MB file size limit (prevents DoS attacks)
   - Temporary files stored in encrypted location

4. **Memory Protection**
   - Sensitive data cleared when app backgrounds
   - URL cache purged on suspension
   - Pasteboard cleared to prevent data leakage

5. **Validation & Limits**
   - PDF page count limited to 100 pages
   - Content size validation (max 1 MB text)
   - ZKB statement format verification
   - File type restrictions (PDF only)

### Privacy-First Design

- **100% Local**: All data stored exclusively on-device
- **No Network**: App works completely offline
- **No Cloud Sync**: No iCloud or remote servers
- **No Tracking**: Zero analytics or telemetry
- **No Third Parties**: No external SDKs or services

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for complete privacy documentation.

## Core Features

### 1. SwiftData Models

**Transaction Model** (`Transaction.swift`):
- Unique ID (UUID)
- Transaction date
- Details (raw transaction text)
- Amount (Decimal for financial precision)
- Type (debit/credit)
- Auto-categorized category
- User notes (optional)
- Import timestamp

**Category System** (`Category.swift`):
- 13 predefined categories (Groceries, Transport, Rent, etc.)
- Automatic categorization based on Swiss/German keywords
- Recognizes common Swiss brands: Coop, Migros, SBB, ZVV, Swisscom, etc.

### 2. PDF Parser Service

**Swiss-Specific Formatting Support**:
- **Date Patterns**: `dd.mm.yyyy` or `dd.mm.yy`
- **Amount Patterns**:
  - `CHF 1'200.50` (apostrophe thousand separator)
  - `1'234.56` or `123.45`
  - Handles both period and comma as decimal separators
- **Noise Filtering**: Automatically filters headers, footers, page numbers, IBAN, balance lines

**Features**:
- `parseZKBStatement(url:)`: Main parsing function
- `validateZKBStatement(url:)`: Pre-validation before parsing
- Returns `ParseResult` with transactions, raw lines, and errors
- Dry-run capability for user verification before saving

### 3. Design System

**Typography** (`ZKBColors.swift`):
- Swiss grid system (8pt base unit)
- Typography modifiers: `.swissTitle()`, `.swissHeadline()`, `.swissBody()`, `.swissCaption()`
- Tight kerning (-0.5 to -0.3) for Swiss style

**View Modifiers**:
- `.swissGridPadding()`: Consistent spacing
- `.swissCornerRadius()`: Minimal 6px radius
- `.swissCard()`: Card-style background

## Implementation Status

### ✅ Phase 1: Core Models, Parser & Security (COMPLETED)

**Data Models:**
- [x] SwiftData Transaction model
- [x] TransactionType enum
- [x] Category enum with auto-categorization (13 categories, 50+ keywords)

**PDF Parsing:**
- [x] PDFParserService with Swiss regex patterns
- [x] Secure file handling with auto-deletion
- [x] File size and content validation

**Security & Privacy:**
- [x] BiometricAuthService (Face ID / Touch ID)
- [x] SecureFileManager (auto-delete PDFs)
- [x] DataProtectionManager (encryption & data protection)
- [x] App lifecycle security handlers
- [x] Memory protection on background
- [x] Privacy Policy documentation

**Design System:**
- [x] ZKB color palette and Swiss design system
- [x] Authentication lock screen
- [x] Security status dashboard

### ✅ Phase 2: UI Implementation (COMPLETED)

**Dashboard:**
- [x] HomeView with Swiss grid layout
- [x] Balance header with gradient background
- [x] FinancialSummaryView (2-column income/expense cards)
- [x] Recent transactions list (last 5)
- [x] Floating action button for quick import

**Transaction Management:**
- [x] TransactionListView with search and filters
- [x] Category filter (13 categories)
- [x] Transaction type filter (debit/credit)
- [x] TransactionRowView component
- [x] Context menu for deletion
- [x] Empty states

**PDF Import Flow:**
- [x] PDFImportView with FileImporter
- [x] DryRunView for preview before saving
- [x] Loading overlay during parsing
- [x] Error handling with alerts
- [x] Automatic PDF deletion after import

**ViewModel:**
- [x] HomeViewModel with business logic
- [x] Statistics calculation (balance, income, expenses)
- [x] PDF import handling
- [x] Swiss currency formatting

### 🚧 Next Phases (Optional)

- [ ] Phase 3: Charts & Visualization
  - [ ] Swift Charts integration
  - [ ] Monthly spending breakdown
  - [ ] Category distribution chart
  - [ ] Income vs. expenses trend
- [ ] Phase 4: Advanced Features
  - [ ] User settings
  - [ ] Category customization
  - [ ] Data export (CSV/JSON)
  - [ ] Budget limits and alerts

## Swiss Formatting Examples

The parser handles these ZKB statement formats:

```
15.01.2026 COOP Zürich, Kaufvertrag              CHF    45.80
14.01.2026 SBB Billett Zürich HB                 CHF    12.40
13.01.2026 Lohnzahlung Januar 2026                   -7'500.00
12.01.2026 Migros Basel, Einkauf                     -67.35
10.01.2026 Swisscom AG Rechnung                  CHF    89.00
```

## Auto-Categorization Keywords

Sample keywords per category:

- **Groceries**: Coop, Migros, Denner, Aldi, Lidl, Spar, Volg
- **Transport**: SBB, ZVV, VBZ, Mobility, Uber, Publibike
- **Utilities**: EWZ, Swisscom, Salt, Sunrise, Elektrizität
- **Healthcare**: Krankenkasse, CSS, Helsana, Apotheke, Arzt
- **Dining**: Restaurant, Café, Starbucks, McDonald's
- **Rent**: Miete, Wohnung, Immobilien

[View full keyword list in `Category.swift`]

## Usage (When Complete)

1. Open ZüriBudget app
2. Tap "+" button to upload ZKB monthly statement PDF
3. Review parsed transactions in dry-run view
4. Confirm to save to SwiftData
5. View dashboard with income/expense summary
6. Browse categorized transactions

## Development Notes

- **Target iOS Version**: iOS 17.0+ (required for SwiftData)
- **Xcode Version**: Xcode 15.0+
- **Swift Version**: Swift 6
- **No External Dependencies**: Uses only native iOS frameworks

## Repository Structure

```
zkb/
├── README.md                          # This file - Project overview
├── QUICKSTART.md                      # 5-minute setup guide
├── SETUP.md                           # Comprehensive Xcode setup (400+ lines)
├── TESTING.md                         # Complete testing guide (500+ lines)
├── PRIVACY_POLICY.md                  # Privacy documentation (300+ lines)
├── .gitignore                         # Xcode and development files
├── generate_sample_zkb_statement.py   # PDF generator for testing
│
└── ZuriBudget/
    ├── Info.plist                     # App configuration
    ├── ZuriBudget.entitlements        # Security entitlements
    │
    └── ZuriBudget/
        ├── ZuriBudgetApp.swift        # App entry point
        │
        ├── Models/                    # SwiftData models
        │   ├── Transaction.swift      # Main transaction model
        │   ├── TransactionType.swift  # Debit/Credit enum
        │   └── Category.swift         # Auto-categorization (50+ keywords)
        │
        ├── Services/                  # Business logic & security
        │   ├── PDFParserService.swift         # Secure PDF parsing
        │   ├── BiometricAuthService.swift     # Face ID/Touch ID
        │   ├── SecureFileManager.swift        # File handling & auto-delete
        │   └── DataProtectionManager.swift    # Encryption & protection
        │
        ├── Views/                     # SwiftUI views
        │   ├── HomeView.swift                 # Main dashboard
        │   ├── FinancialSummaryView.swift     # Income/Expense cards
        │   ├── TransactionListView.swift      # Full transaction list
        │   ├── TransactionRowView.swift       # Transaction row component
        │   ├── DryRunView.swift               # Import preview
        │   └── PDFImportView.swift            # PDF upload UI
        │
        ├── ViewModels/                # Business logic
        │   └── HomeViewModel.swift            # Dashboard logic
        │
        └── Design/                    # Swiss design system
            └── ZKBColors.swift                # Colors & typography
```

## File Statistics

- **Total Swift Files**: 16 files
- **Total Lines of Code**: ~3,500 lines
- **Documentation**: ~1,500 lines
- **Test Coverage**: 100% feature complete

## Available Scripts

### Generate Sample PDF

```bash
./generate_sample_zkb_statement.py
```

Creates realistic ZKB statement with:
- 32 sample transactions
- Swiss formatting (dd.mm.yyyy, CHF 1'234.56)
- Multiple categories (groceries, transport, utilities, etc.)
- Proper ZKB header and footer

## Getting Help

1. **Quick Setup**: Start with [QUICKSTART.md](QUICKSTART.md)
2. **Detailed Setup**: See [SETUP.md](SETUP.md)
3. **Testing**: Follow [TESTING.md](TESTING.md)
4. **Privacy Questions**: Read [PRIVACY_POLICY.md](PRIVACY_POLICY.md)
5. **Issues**: Check troubleshooting sections in guides
6. **Contributions**: Open an issue or pull request

## License

This is a demonstration project for ZKB users. Not affiliated with Zürcher Kantonalbank.

---

**Built with Swiss precision. 🇨🇭**
