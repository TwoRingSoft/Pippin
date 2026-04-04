import Foundation
#if canImport(SwiftUI)
import SwiftUI

@MainActor
public final class WhatsNewViewModel: ObservableObject {
    @Published public var entries: [ChangelogEntry] = []
    @Published public var shouldPresent: Bool = false

    private let environment: Environment
    private let changelogBundle: Bundle

    public init(environment: Environment, changelogBundle: Bundle) {
        self.environment = environment
        self.changelogBundle = changelogBundle
        checkForNewEntries()
    }
}

private extension WhatsNewViewModel {
    func checkForNewEntries() {
        guard let lastVersion = environment.lastLaunchedVersion else {
            print("[WhatsNew] No lastLaunchedVersion — first launch, skipping")
            return
        }

        let currentVersion = String(describing: environment.semanticVersion)
        let previousVersion = String(describing: lastVersion)
        print("[WhatsNew] currentVersion=\(currentVersion) previousVersion=\(previousVersion)")
        guard currentVersion != previousVersion else {
            print("[WhatsNew] Versions match, skipping")
            return
        }

        guard let url = changelogBundle.url(forResource: "CHANGELOG", withExtension: "md") else {
            print("[WhatsNew] CHANGELOG.md not found in bundle: \(changelogBundle)")
            return
        }
        guard let markdown = try? String(contentsOf: url) else {
            print("[WhatsNew] Failed to read CHANGELOG.md at \(url)")
            return
        }
        print("[WhatsNew] Loaded CHANGELOG.md (\(markdown.count) chars)")

        let allEntries = ChangelogParser.parse(from: markdown)
        print("[WhatsNew] Parsed \(allEntries.count) entries: \(allEntries.map { $0.version })")

        let newEntries = ChangelogParser.entriesSince(previousVersion, upTo: currentVersion, from: allEntries)
        print("[WhatsNew] \(newEntries.count) new entries since \(previousVersion) up to \(currentVersion)")

        if !newEntries.isEmpty {
            entries = newEntries
            shouldPresent = true
        }
    }
}
#endif
