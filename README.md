# ZüriBudget - iOS Finance Tracker for ZKB Users

A native iOS app built with SwiftUI that allows **Zürcher Kantonalbank (ZKB)** users to track their finances by parsing uploaded PDF monthly statements.

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
│   ├── ZuriBudgetApp.swift          # App entry point with SwiftData config
│   ├── Models/
│   │   ├── Transaction.swift         # SwiftData model for transactions
│   │   ├── TransactionType.swift     # Enum: debit/credit
│   │   └── Category.swift            # Enum: auto-categorization logic
│   ├── Services/
│   │   └── PDFParserService.swift    # ZKB PDF parsing engine
│   ├── Views/
│   │   └── (TBD: HomeView, etc.)
│   ├── ViewModels/
│   │   └── (TBD)
│   └── Design/
│       └── ZKBColors.swift           # Swiss design system & colors
```

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

### ✅ Phase 1: Models & Parser (COMPLETED)

- [x] SwiftData Transaction model
- [x] TransactionType enum
- [x] Category enum with auto-categorization (13 categories, 50+ keywords)
- [x] PDFParserService with Swiss regex patterns
- [x] ZKB color palette and design system
- [x] App entry point with SwiftData configuration

### 🚧 Next Phases (TBD)

- [ ] Phase 2: UI Implementation
  - [ ] HomeView with Swiss grid layout
  - [ ] FileImporter integration
  - [ ] Transaction list view
  - [ ] Dry-run verification view
- [ ] Phase 3: Charts & Visualization
  - [ ] Swift Charts integration
  - [ ] Minimalist chart styling
- [ ] Phase 4: Refinement
  - [ ] User settings
  - [ ] Category editing
  - [ ] Export functionality

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

## License

This is a demonstration project for ZKB users. Not affiliated with Zürcher Kantonalbank.

---

**Built with Swiss precision. 🇨🇭**
