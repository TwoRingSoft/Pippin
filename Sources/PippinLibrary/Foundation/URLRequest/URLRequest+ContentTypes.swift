//
//  URLRequest+ContentTypes.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 8/8/20.
//

import Foundation

public enum ContentType {
    public enum Application: String {
        case x_www_form_URLEncoded = "x-www-form-urlencoded"
        case json
    }
    case application(Application)

    public enum Multipart: String {
        case formData = "form-data"
    }
    case multipart(Multipart)

    public var description: String {
        switch self {
        case .application(let type):
            return "application/" + type.rawValue
        case .multipart(let type):
            return "multipart/" + type.rawValue
        }
    }
}
