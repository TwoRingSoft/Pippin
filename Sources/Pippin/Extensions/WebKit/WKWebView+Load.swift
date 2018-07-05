//
//  WKWebView+Load.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/28/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Foundation
import WebKit

public extension WKWebView {

    func loadHTML(fromFile file: String, htmlPrologueFile: String? = nil, htmlEpilogueFile: String? = nil, baseURL: URL? = nil) throws {
        var htmlComponents = [String]()

        if let prologue = htmlPrologueFile {
            try htmlComponents.append(String(contentsOfResource: prologue, withExtension: "html"))
        }

        try htmlComponents.append(String(contentsOfResource: file))

        if let epilogue = htmlEpilogueFile {
            try htmlComponents.append(String(contentsOfResource: epilogue, withExtension: "html"))
        }

        loadHTMLString(htmlComponents.joined(), baseURL: baseURL)
    }

}
