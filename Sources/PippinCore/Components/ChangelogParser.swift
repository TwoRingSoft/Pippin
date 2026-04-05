//
//  ChangelogParser.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/30/26.
//

import Foundation

public struct ChangelogEntry {
    public let version: String
    public let date: String?
    public let content: String

    public init(version: String, date: String?, content: String) {
        self.version = version
        self.date = date
        self.content = content
    }

    /// The entry formatted as markdown with a version header.
    public var fullMarkdown: String {
        var header = "## \(version)"
        if let date = date {
            header += " — \(date)"
        }
        return "\(header)\n\n\(content)"
    }
}

public enum ChangelogParser {
    /// Parse a Keep a Changelog format markdown string into entries.
    /// Skips `[Unreleased]` sections.
    public static func parse(from markdown: String) -> [ChangelogEntry] {
        var entries: [ChangelogEntry] = []
        var currentVersion: String?
        var currentDate: String?
        var currentContent: [String] = []

        let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("## ") {
                if let version = currentVersion {
                    entries.append(ChangelogEntry(
                        version: version,
                        date: currentDate,
                        content: currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    ))
                }

                let pattern = #"^##\s*\[([^\]]+)\](?:\s*-?\s*(.+))?"#
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
                   let versionRange = Range(match.range(at: 1), in: trimmed) {

                    let version = String(trimmed[versionRange])

                    if version.lowercased() == "unreleased" {
                        currentVersion = nil
                        currentDate = nil
                        currentContent = []
                        continue
                    }

                    currentVersion = version

                    if match.numberOfRanges > 2, let dateRange = Range(match.range(at: 2), in: trimmed) {
                        currentDate = String(trimmed[dateRange])
                    } else {
                        currentDate = nil
                    }
                } else {
                    currentVersion = nil
                    currentDate = nil
                }

                currentContent = []
            } else if currentVersion != nil {
                currentContent.append(String(line))
            }
        }

        if let version = currentVersion {
            entries.append(ChangelogEntry(
                version: version,
                date: currentDate,
                content: currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            ))
        }

        return entries
    }

    /// Extract entries between two semantic versions (exclusive of `since`, inclusive of current).
    /// Entries are assumed to be ordered newest-first as in a standard changelog.
    public static func entriesSince(_ sinceVersion: String, upTo currentVersion: String, from entries: [ChangelogEntry]) -> [ChangelogEntry] {
        guard let currentIdx = entries.firstIndex(where: { $0.version == currentVersion }),
              let sinceIdx = entries.firstIndex(where: { $0.version == sinceVersion }),
              currentIdx < sinceIdx else {
            return []
        }
        return Array(entries[currentIdx..<sinceIdx])
    }
}
