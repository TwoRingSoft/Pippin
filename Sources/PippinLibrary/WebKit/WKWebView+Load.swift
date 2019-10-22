//
//  WKWebView+Load.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 7/28/17.
//  Copyright © 2019 Two Ring Software. All rights reserved.
//

import Foundation
import WebKit

public extension WKWebView {

    func loadHTML(fromFile file: String, htmlPrologueFile: String? = nil, htmlEpilogueFile: String? = nil, baseURL: URL? = nil, bundle: Bundle = Bundle.main) throws {
        var htmlComponents = [String]()

        if let prologue = htmlPrologueFile {
            try htmlComponents.append(String(contentsOfResource: prologue, withExtension: "html", inBundle: bundle))
        }

        try htmlComponents.append(String(contentsOfResource: file, inBundle: bundle))

        if let epilogue = htmlEpilogueFile {
            try htmlComponents.append(String(contentsOfResource: epilogue, withExtension: "html", inBundle: bundle))
        }

        loadHTMLString(htmlComponents.joined(), baseURL: baseURL)
    }

}
