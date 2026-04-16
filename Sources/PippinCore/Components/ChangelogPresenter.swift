//
//  ChangelogPresenter.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/30/26.
//

import Foundation
#if canImport(UIKit)
import UIKit
import WebKit

public class ChangelogPresenter {
    private let environment: Environment
    private let changelogBundle: Bundle

    public init(environment: Environment, changelogBundle: Bundle = Bundle.main) {
        self.environment = environment
        self.changelogBundle = changelogBundle
    }

    /// Check whether a "What's New" screen should be shown, and present it if so.
    /// Call this after your root view controller is visible.
    public func presentWhatsNewIfNeeded(from presenter: UIViewController) {
        guard let entries = whatsNewEntries(), !entries.isEmpty else { return }

        let markdown = entries.map { $0.fullMarkdown }.joined(separator: "\n\n")
        let vc = ChangelogViewController(title: "What's New", markdown: markdown)
        let nav = UINavigationController(rootViewController: vc)
        presenter.present(nav, animated: true)
    }

    /// Present the full changelog.
    public func presentFullChangelog(from presenter: UIViewController) {
        guard let markdown = loadChangelogMarkdown() else { return }

        let vc = ChangelogViewController(title: "Changelog", markdown: markdown)
        let nav = UINavigationController(rootViewController: vc)
        presenter.present(nav, animated: true)
    }

    /// Returns a view controller displaying the what's-new entries, or nil if there are none.
    public func whatsNewViewController() -> UIViewController? {
        guard let entries = whatsNewEntries(), !entries.isEmpty else { return nil }
        let markdown = entries.map { $0.fullMarkdown }.joined(separator: "\n\n")
        return ChangelogViewController(title: "What's New", markdown: markdown)
    }

    /// Returns a view controller displaying the full changelog, or nil if not available.
    public func fullChangelogViewController() -> UIViewController? {
        guard let markdown = loadChangelogMarkdown() else { return nil }
        let entries = ChangelogParser.parse(from: markdown)
        let versioned = entries.map { $0.fullMarkdown }.joined(separator: "\n\n")
        return ChangelogViewController(title: "Changelog", markdown: versioned)
    }

    /// Returns changelog entries since the last launched build, or nil if
    /// this is a first launch or the build number hasn't changed.
    /// Uses build numbers (`+N` in changelog section headers) so RC-to-RC upgrades
    /// also trigger the display, not just marketing version changes.
    public func whatsNewEntries() -> [ChangelogEntry]? {
        guard let lastBuild = environment.lastLaunchedBuild else { return nil }

        let currentBuild = environment.currentBuild
        guard currentBuild != lastBuild else { return nil }

        guard let markdown = loadChangelogMarkdown() else { return nil }

        let allEntries = ChangelogParser.parse(from: markdown)
        let entries = ChangelogParser.entriesSince(build: lastBuild, upTo: currentBuild, from: allEntries)
        return entries.isEmpty ? nil : entries
    }

    private func loadChangelogMarkdown() -> String? {
        guard let url = changelogBundle.url(forResource: "CHANGELOG", withExtension: "md"),
              let markdown = try? String(contentsOf: url) else { return nil }
        return markdown
    }
}

public class ChangelogViewController: UIViewController {
    private let markdown: String
    private let webView = WKWebView()

    public init(title: String, markdown: String) {
        self.markdown = markdown
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissModal))

        view.backgroundColor = .clear
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let html = Self.htmlPage(from: Self.markdownToHTML(markdown))
        webView.loadHTMLString(html, baseURL: nil)
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
    }

    static func markdownToHTML(_ markdown: String) -> String {
        var html = ""
        var inList = false

        for line in markdown.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("### ") {
                if inList { html += "</ul>"; inList = false }
                html += "<h3>\(trimmed.dropFirst(4))</h3>"
            } else if trimmed.hasPrefix("## ") {
                if inList { html += "</ul>"; inList = false }
                html += "<h2>\(trimmed.dropFirst(3))</h2>"
            } else if trimmed.hasPrefix("# ") {
                if inList { html += "</ul>"; inList = false }
                html += "<h1>\(trimmed.dropFirst(2))</h1>"
            } else if trimmed.hasPrefix("- ") {
                if !inList { html += "<ul>"; inList = true }
                html += "<li>\(trimmed.dropFirst(2))</li>"
            } else if trimmed.isEmpty {
                if inList { html += "</ul>"; inList = false }
            } else {
                html += "<p>\(trimmed)</p>"
            }
        }
        if inList { html += "</ul>" }

        html = html.replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "<strong>$1</strong>", options: .regularExpression)
        html = html.replacingOccurrences(of: "`([^`]+)`", with: "<code>$1</code>", options: .regularExpression)

        return html
    }

    static func htmlPage(from body: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            :root { color-scheme: light dark; }
            body {
                font-family: -apple-system, system-ui;
                font-size: 16px;
                line-height: 1.5;
                padding: 16px;
                margin: 0;
                background: transparent;
            }
            h1 { font-size: 1.5em; margin-top: 0; }
            h2 { font-size: 1.3em; margin-top: 1.2em; border-bottom: 1px solid rgba(128,128,128,0.3); padding-bottom: 4px; }
            h3 { font-size: 1.1em; margin-top: 1em; }
            ul { padding-left: 20px; }
            li { margin-bottom: 4px; }
            code {
                background: rgba(128,128,128,0.15);
                padding: 2px 5px;
                border-radius: 4px;
                font-size: 0.9em;
            }
        </style>
        </head>
        <body>\(body)</body>
        </html>
        """
    }
}
#endif
