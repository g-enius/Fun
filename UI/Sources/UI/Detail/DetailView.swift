//
//  DetailView.swift
//  UI
//
//  SwiftUI view for Detail screen
//

import SwiftUI

import FunCore
import FunViewModel

public struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel

    public init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.itemTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack {
                        Text(viewModel.category)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }

                Divider()

                // Description
                Text(L10n.Detail.howUsed)
                    .font(.headline)

                DescriptionContentView(text: viewModel.itemDescription)

                Divider()

                // Navigation info
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .accessibilityHidden(true)
                        Text(L10n.Detail.pushNavigation)
                            .font(.caption)
                    }
                    Text(L10n.Detail.usingCoordinatorPattern)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            .padding()
        }
    }
}

// MARK: - Description Content View

/// Renders description text with code blocks styled differently
private struct DescriptionContentView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(parseContent().enumerated()), id: \.offset) { _, block in
                switch block {
                case .text(let content):
                    Text(markdownAttributedString(from: content))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                case .code(let content, let language):
                    CodeBlockView(code: content, language: language)
                }
            }
        }
    }

    private func parseContent() -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        var remaining = text

        while let startRange = remaining.range(of: "```") {
            // Add text before code block
            let textBefore = String(remaining[..<startRange.lowerBound])
            if !textBefore.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                blocks.append(.text(textBefore))
            }

            // Find end of code block
            let afterStart = remaining[startRange.upperBound...]
            if let endRange = afterStart.range(of: "```") {
                let codeContent = String(afterStart[..<endRange.lowerBound])

                // Extract language hint (e.g., "swift" from ```swift)
                let lines = codeContent.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
                let language = lines.first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? ""
                let code = lines.count > 1 ? String(lines[1]) : ""

                blocks.append(.code(code.trimmingCharacters(in: .newlines), language))
                remaining = String(afterStart[endRange.upperBound...])
            } else {
                // No closing ```, treat rest as text
                blocks.append(.text(String(remaining[startRange.lowerBound...])))
                remaining = ""
            }
        }

        // Add remaining text
        if !remaining.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            blocks.append(.text(remaining))
        }

        return blocks
    }

    private func markdownAttributedString(from text: String) -> AttributedString {
        let markdownText = text
            .replacingOccurrences(of: "• ", with: "- ")
        return (try? AttributedString(
            markdown: markdownText,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(text)
    }
}

// MARK: - Content Block

private enum ContentBlock {
    case text(String)
    case code(String, String) // code, language
}

// MARK: - Code Block View

/// Code block view that adapts styling based on color scheme.
/// Demonstrates @Environment usage for reading system settings.
private struct CodeBlockView: View {
    let code: String
    let language: String

    // MARK: - Environment

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color(.systemGray4) : Color.clear
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !language.isEmpty {
                Text(language)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }

            Text(code)
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(.primary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

// MARK: - Previews

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(viewModel: PreviewHelper.makeDetailViewModel())
                .navigationTitle("Detail")
        }
    }
}
