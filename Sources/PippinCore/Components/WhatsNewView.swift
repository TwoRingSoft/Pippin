import Foundation
#if canImport(SwiftUI)
import SwiftUI

public struct WhatsNewView: View {
    private let entries: [ChangelogEntry]
    private let onDismiss: () -> Void

    public init(entries: [ChangelogEntry], onDismiss: @escaping () -> Void) {
        self.entries = entries
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(entries, id: \.version) { entry in
                        entryView(entry)
                    }
                }
                .padding()
            }
            .navigationTitle("What's New")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDismiss)
                }
            }
        }
    }
}

private extension WhatsNewView {
    func entryView(_ entry: ChangelogEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.version)
                    .font(.headline)
                if let date = entry.date {
                    Spacer()
                    Text(date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(contentLines(entry.content), id: \.self) { line in
                if line.hasPrefix("### ") {
                    Text(String(line.dropFirst(4)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                } else if line.hasPrefix("- ") {
                    HStack(alignment: .top, spacing: 8) {
                        Text("\u{2022}")
                        Text(String(line.dropFirst(2)))
                    }
                    .font(.body)
                }
            }
        }
    }

    func contentLines(_ content: String) -> [String] {
        content.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}
#endif
