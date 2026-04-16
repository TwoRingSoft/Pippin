import XCTest
import SwiftArmcknight
@testable import Pippin

final class ChangelogParserTests: XCTestCase {

    // MARK: - Fixtures

    /// Changelog representing a full RC cycle followed by a final release.
    /// Document order: newest first.
    private let changelog = """
    ## [Unreleased]

    ## [1.0.1+44] 2026-04-16
    - Final release note

    ## [1.0.1-RC2+43] 2026-04-15
    - RC2 note

    ## [1.0.1-RC1+42] 2026-04-14
    - RC1 note

    ## [1.0.0+40] 2026-03-01
    - Previous release note

    ## [0.9.0+10] 2026-01-01
    - Old note
    """

    /// Changelog after RC consolidation — RC sections are replaced by a single final entry.
    private let consolidatedChangelog = """
    ## [Unreleased]

    ## [1.0.1+44] 2026-04-16
    - RC1 note
    - RC2 note
    - Final release note

    ## [1.0.0+40] 2026-03-01
    - Previous release note
    """

    private func entries(from markdown: String) -> [ChangelogEntry] {
        ChangelogParser.parse(from: markdown)
    }

    private func build(_ n: UInt) -> Build {
        Build(String(n))!
    }

    // MARK: - RC1 → RC2

    func testRC1ToRC2ShowsRC2Entry() {
        let result = ChangelogParser.entriesSince(
            build: build(42),
            upTo: build(43),
            from: entries(from: changelog)
        )
        XCTAssertEqual(result.map { $0.version }, ["1.0.1-RC2+43"])
    }

    // MARK: - RC2 → final release (after consolidation)

    func testRC2ToFinalAfterConsolidationShowsFinalEntry() {
        // After `make deploy`, the RC sections are gone. The tester's last build (43)
        // is no longer in the changelog, but the final entry (44) is still found.
        let result = ChangelogParser.entriesSince(
            build: build(43),
            upTo: build(44),
            from: entries(from: consolidatedChangelog)
        )
        XCTAssertEqual(result.map { $0.version }, ["1.0.1+44"])
    }

    // MARK: - Old release → new release (spanning multiple entries)

    func testOldReleaseToNewShowsAllEntriesInRange() {
        // User on build 40 upgrades to 44 — should see RC1, RC2, and final.
        let result = ChangelogParser.entriesSince(
            build: build(40),
            upTo: build(44),
            from: entries(from: changelog)
        )
        XCTAssertEqual(result.map { $0.version }, ["1.0.1+44", "1.0.1-RC2+43", "1.0.1-RC1+42"])
    }

    // MARK: - Same build (no change)

    func testSameBuildReturnsEmpty() {
        let result = ChangelogParser.entriesSince(
            build: build(44),
            upTo: build(44),
            from: entries(from: changelog)
        )
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Entries without +N suffix are skipped

    func testEntriesWithoutBuildNumberAreSkipped() {
        let legacyChangelog = """
        ## [1.1.0] 2026-05-01
        - No build number here

        ## [1.0.1+44] 2026-04-16
        - Has build number
        """
        let result = ChangelogParser.entriesSince(
            build: build(43),
            upTo: build(44),
            from: entries(from: legacyChangelog)
        )
        XCTAssertEqual(result.map { $0.version }, ["1.0.1+44"])
    }

    // MARK: - Build number exactly at since boundary is excluded

    func testSinceBoundaryIsExclusive() {
        let result = ChangelogParser.entriesSince(
            build: build(42),
            upTo: build(44),
            from: entries(from: changelog)
        )
        // Build 42 itself should NOT be included; 43 and 44 should be.
        XCTAssertFalse(result.map { $0.version }.contains("1.0.1-RC1+42"))
        XCTAssertTrue(result.map { $0.version }.contains("1.0.1-RC2+43"))
        XCTAssertTrue(result.map { $0.version }.contains("1.0.1+44"))
    }

    // MARK: - Build number at current boundary is included

    func testCurrentBoundaryIsInclusive() {
        let result = ChangelogParser.entriesSince(
            build: build(43),
            upTo: build(44),
            from: entries(from: changelog)
        )
        XCTAssertTrue(result.map { $0.version }.contains("1.0.1+44"))
    }
}
