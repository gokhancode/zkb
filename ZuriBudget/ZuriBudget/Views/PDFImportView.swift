//
//  PDFImportView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  PDF import UI with FileImporter

import SwiftUI
import UniformTypeIdentifiers

struct PDFImportView: View {
    let onFileSelected: (URL) -> Void

    @State private var showFileImporter = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: SwissTypography.baseUnit * 3) {
            // Icon
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.zkbBlue)

            // Title
            Text("Import ZKB Statement")
                .swissTitle()
                .foregroundColor(.textPrimary)

            // Description
            Text("Upload your monthly PDF statement from Zürcher Kantonalbank to automatically track your transactions")
                .swissBody()
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .swissGridPadding(2)

            // Import button
            Button {
                showFileImporter = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 20))

                    Text("Choose PDF")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .swissGridPadding(2)
                .foregroundColor(.white)
                .background(Color.zkbBlue)
                .swissCornerRadius()
            }
            .swissGridPadding(2)

            // Security features
            VStack(alignment: .leading, spacing: SwissTypography.baseUnit) {
                Text("Security Features")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)
                    .kerning(0.5)

                SecurityFeatureRow(
                    icon: "lock.shield.fill",
                    text: "PDF deleted after import"
                )

                SecurityFeatureRow(
                    icon: "checkmark.shield.fill",
                    text: "10 MB file size limit"
                )

                SecurityFeatureRow(
                    icon: "eye.fill",
                    text: "Preview before saving"
                )

                SecurityFeatureRow(
                    icon: "iphone.radiowaves.left.and.right",
                    text: "100% local processing"
                )
            }
            .swissGridPadding(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .swissCornerRadius()
        }
        .swissGridPadding(2)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleFileImportResult(result)
        }
    }

    // MARK: - File Import Handler

    private func handleFileImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                onFileSelected(url)
            }
        case .failure(let error):
            print("File import error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Security Feature Row

struct SecurityFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: SwissTypography.baseUnit) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.emeraldGreen)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview {
    PDFImportView { url in
        print("Selected: \(url)")
    }
}
