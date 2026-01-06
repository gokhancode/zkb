# Privacy Policy for ZüriBudget

**Last Updated**: January 6, 2026

## Our Commitment to Privacy

ZüriBudget is designed with **privacy-first principles**. Your financial data is personal and sensitive, and we treat it with the highest level of security and confidentiality.

## Data Collection and Storage

### What Data We Collect

ZüriBudget collects and stores the following data **locally on your device only**:

- **Transaction Data**: Information parsed from your ZKB PDF statements, including:
  - Transaction dates
  - Transaction descriptions
  - Transaction amounts
  - Auto-assigned categories
  - Optional user notes

### What Data We DO NOT Collect

We **never** collect, transmit, or have access to:

- Your actual ZKB account credentials
- Your ZKB account number or IBAN
- Your personal identity information
- Your device location
- Any usage analytics or telemetry
- Any data that leaves your device

## Data Storage and Security

### Local-Only Storage

- **100% On-Device**: All transaction data is stored exclusively in a local database on your iOS device using Apple's SwiftData framework
- **No Cloud Sync**: We do not use iCloud or any other cloud storage service
- **No Remote Servers**: We do not operate any backend servers or remote databases
- **No Network Transmission**: Your financial data never leaves your device

### Encryption and Protection

ZüriBudget implements multiple layers of security:

1. **iOS Data Protection**: All app data is protected by iOS's built-in encryption when your device is locked
2. **Complete File Protection**: Database files use FileProtectionType.complete, requiring device unlock for access
3. **Biometric Authentication**: Optional Face ID/Touch ID protection (enabled by default)
4. **Secure File Handling**: PDF statements are automatically deleted after parsing
5. **Memory Protection**: Sensitive data is cleared from memory when the app backgrounds

### PDF Processing

When you import a ZKB PDF statement:

1. You select the file using iOS's secure file picker
2. The file is copied to a secure temporary location with full encryption
3. The PDF is parsed to extract transaction data
4. **The PDF is immediately and securely deleted** (overwritten with random data, then removed)
5. Only the parsed transaction data (dates, descriptions, amounts) is retained

**Important**: We never retain copies of your original PDF statements.

## Data Sharing

**We do not share your data with anyone**. Period.

- No third-party analytics
- No advertising partners
- No data brokers
- No affiliate partnerships
- No government or law enforcement access (we don't have access to your data)

## Data Deletion

### User Control

You have complete control over your data:

- **Delete Individual Transactions**: Remove any transaction from the app
- **Delete All Data**: Uninstalling the app permanently deletes all stored data
- **No Data Recovery**: Once deleted from your device, data cannot be recovered (we have no backups)

### Automatic Deletion

- PDF files are automatically deleted immediately after parsing
- Temporary processing files are securely wiped when no longer needed
- Cache data is cleared when the app backgrounds

## Third-Party Services

### Services We DO NOT Use

ZüriBudget does not integrate with any third-party services:

- ❌ No analytics services (Google Analytics, Mixpanel, etc.)
- ❌ No crash reporting (Crashlytics, Sentry, etc.)
- ❌ No advertising networks
- ❌ No social media integration
- ❌ No cloud storage providers
- ❌ No payment processors

### Apple Services We Use

We use only Apple's built-in frameworks:

- **SwiftData**: Local database storage (encrypted, on-device only)
- **PDFKit**: PDF parsing (runs locally, no network access)
- **LocalAuthentication**: Face ID/Touch ID (biometric data never leaves your device)
- **iOS Sandbox**: App runs in a restricted environment with limited file access

## Permissions

ZüriBudget requests the following iOS permissions:

- **File Access**: Only when you explicitly select a PDF file to import (via iOS secure file picker)
- **Biometric Authentication**: Optional Face ID/Touch ID for app unlock (can be disabled in settings)

We **never** request:

- Location services
- Camera or photo library access
- Contacts access
- Calendar access
- Network/internet access (the app works offline)

## Children's Privacy

ZüriBudget is not directed at children under 13. We do not knowingly collect data from children.

## Changes to This Policy

If we update this privacy policy, we will:

1. Update the "Last Updated" date at the top
2. Include the changes in the app release notes
3. Notify users via an in-app message (if applicable)

Material changes will be communicated clearly before taking effect.

## Data Portability

Your data is yours:

- All transaction data can be exported (feature to be implemented)
- Export formats: CSV, JSON (planned)
- You can transfer your exported data to any other financial app

## Compliance

### Swiss Data Protection

While ZüriBudget is designed for ZKB (Zürcher Kantonalbank) users, we comply with Swiss data protection principles:

- **Data Minimization**: We only process data necessary for app functionality
- **Purpose Limitation**: Data is used only for personal finance tracking
- **Transparency**: This policy clearly explains our data practices

### GDPR Compliance

For users in the EU:

- **Right to Access**: You can view all your data within the app
- **Right to Deletion**: Delete individual or all transactions anytime
- **Right to Portability**: Export your data (feature planned)
- **Right to Erasure**: Uninstall the app to permanently delete all data

Note: Since all data is local and we have no servers, we cannot "process requests" - you have direct control.

## Security Incidents

In the unlikely event of a security vulnerability:

1. We will release a security update immediately
2. Users will be notified via app update notes
3. Details will be published in the GitHub repository

**Important**: Since your data never leaves your device, server breaches are impossible.

## Contact

ZüriBudget is an open-source project. For privacy concerns or questions:

- **GitHub Issues**: [Report an issue](https://github.com/gokhancode/zkb/issues)
- **Security Vulnerabilities**: Please report security issues privately via GitHub Security Advisories

## Legal Disclaimer

ZüriBudget is **not affiliated with, endorsed by, or supported by Zürcher Kantonalbank (ZKB)**.

This app is provided as-is for personal use. We make no warranties about accuracy of parsed data. Always verify transactions against your official ZKB statements.

## Your Consent

By using ZüriBudget, you consent to this privacy policy.

You can withdraw consent at any time by:

1. Deleting all transactions within the app
2. Uninstalling the app from your device

---

## Summary (TL;DR)

✅ **100% local storage** - Data never leaves your device
✅ **No network access** - App works completely offline
✅ **Auto-delete PDFs** - Statements deleted after parsing
✅ **Full encryption** - Protected when device is locked
✅ **Biometric lock** - Face ID/Touch ID protection
✅ **No tracking** - Zero analytics or telemetry
✅ **No cloud sync** - Not even iCloud
✅ **Open source** - Code is auditable
✅ **Your control** - Delete data anytime

**Your financial data is yours alone. We can't access it, we don't want it, and we'll never share it.**

---

**Built with Swiss precision and privacy. 🇨🇭🔒**
