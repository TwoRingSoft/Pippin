//
//  NSURLResponse+Status.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 4/24/20.
//

import Foundation

/// - SeeAlso: http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
public enum HTTPResponseCode: RawRepresentable {
    enum Unassigned {
        static let information = Set(104...199)
        static let success = Set(209...225).union(Set(227...299))
        static let redirect = Set(309...399)
        static let refused = Set(418...420).union(Set([427, 430])).union(Set(432...450)).union(Set(452...499))
        static let error = Set([509]).union(Set(512...599))
        static func contains(rawValue: Int) -> Bool {
            return [information, success, redirect, refused, error].filter({ $0.contains(rawValue) }).count > 0
        }
    }

    public init?(response: URLResponse) {
        guard
            let httpResponse = response as? HTTPURLResponse,
            let code = HTTPResponseCode(rawValue: httpResponse.statusCode)
            else {
                return nil
        }

        self = code
    }

    public typealias RawValue = Int

    public init?(rawValue: Int) {
        guard rawValue >= 100 && rawValue < 600 && !Unassigned.contains(rawValue: rawValue) else {
            return nil
        }

        if rawValue < 200 {
            guard let value = Information(rawValue: rawValue) else { return nil }
            self = .information(value)
        } else if rawValue < 300 {
            guard let value = Success(rawValue: rawValue) else { return nil }
            self = .success(value)
        } else if rawValue < 400 {
            guard let value = Redirect(rawValue: rawValue) else { return nil }
            self = .redirect(value)
        } else if rawValue < 500 {
            guard let value = Refused(rawValue: rawValue) else { return nil }
            self = .refused(value)
        } else {
            guard let value = Error(rawValue: rawValue) else { return nil }
            self = .error(value)
        }
    }

    public var rawValue: Int {
        switch self {
            case .information(let information): return information.rawValue
            case .success(let success): return success.rawValue
            case .redirect(let redirect): return redirect.rawValue
            case .refused(let refused): return refused.rawValue
            case .error(let error): return error.rawValue
        }
    }

    case information(Information)
    case success(Success)
    case redirect(Redirect)
    case refused(Refused)
    case error(Error)

    public enum Information: Int {
        case `continue` =                       100 // [RFC7231, Section 6.2.1]
        case switchingProtocols =               101 // [RFC7231, Section 6.2.2]
        case processing =                       102 // [RFC2518]
        case earlyHints =                       103 // [RFC8297]
    }

    public enum Success: Int {
        case ok =                               200 // [RFC7231, Section 6.3.1]
        case created =                          201 // [RFC7231, Section 6.3.2]
        case accepted =                         202 // [RFC7231, Section 6.3.3]
        case nonauthoritativeInformation =      203 // [RFC7231, Section 6.3.4]
        case noContent =                        204 // [RFC7231, Section 6.3.5]
        case resetContent =                     205 // [RFC7231, Section 6.3.6]
        case partialContent =                   206 // [RFC7233, Section 4.1]
        case multiStatus =                      207 // [RFC4918]
        case alreadyReported =                  208 // [RFC5842]
        case imUsed =                           226 // [RFC3229]
    }

    public enum Redirect: Int {
        case multipleChoices =                  300 // [RFC7231, Section 6.4.1]
        case movedPermanently =                 301 // [RFC7231, Section 6.4.2]
        case found =                            302 // [RFC7231, Section 6.4.3]
        case seeOther =                         303 // [RFC7231, Section 6.4.4]
        case notModified =                      304 // [RFC7232, Section 4.1]
        case useProxy =                         305 // [RFC7231, Section 6.4.5]
        case unused =                           306 // [RFC7231, Section 6.4.6]
        case temporaryRedirect =                307 // [RFC7231, Section 6.4.7]
        case permanentRedirect =                308 // [RFC7538]
    }

    public enum Refused: Int {
        case badRequest =                       400 // [RFC7231, Section 6.5.1]
        case unauthorized =                     401 // [RFC7235, Section 3.1]
        case paymentRequired =                  402 // [RFC7231, Section 6.5.2]
        case forbidden =                        403 // [RFC7231, Section 6.5.3]
        case notFound =                         404 // [RFC7231, Section 6.5.4]
        case methodNotAllowed =                 405 // [RFC7231, Section 6.5.5]
        case notAcceptable =                    406 // [RFC7231, Section 6.5.6]
        case proxyAuthenticationRequired =      407 // [RFC7235, Section 3.2]
        case requestTimeout =                   408 // [RFC7231, Section 6.5.7]
        case conflict =                         409 // [RFC7231, Section 6.5.8]
        case gone =                             410 // [RFC7231, Section 6.5.9]
        case lengthRequired =                   411 // [RFC7231, Section 6.5.10]
        case preconditionFailed =               412 // [RFC7232, Section 4.2][RFC8144, Section 3.2]
        case payloadTooLarge =                  413 // [RFC7231, Section 6.5.11]
        case uriTooLong =                       414 // [RFC7231, Section 6.5.12]
        case unsupportedMediaType =             415 // [RFC7231, Section 6.5.13][RFC7694, Section 3]
        case rangeNotSatisfiable =              416 // [RFC7233, Section 4.4]
        case expectationFailed =                417 // [RFC7231, Section 6.5.14]
        case misdirectedRequest =               421 // [RFC7540, Section 9.1.2]
        case unprocessableEntity =              422 // [RFC4918]
        case locked =                           423 // [RFC4918]
        case failedDependency =                 424 // [RFC4918]
        case tooEarly =                         425 // [RFC8470]
        case upgradeRequired =                  426 // [RFC7231, Section 6.5.15]
        case preconditionRequired =             428 // [RFC6585]
        case tooManyRequests =                  429 // [RFC6585]
        case requestHeaderFieldsTooLarge =      431 // [RFC6585]
        case unavailableForLegalReasons =       451 // [RFC7725]
    }

    public enum Error: Int {
        case internalServerError =              500 // [RFC7231, Section 6.6.1]
        case notImplemented =                   501 // [RFC7231, Section 6.6.2]
        case badGateway =                       502 // [RFC7231, Section 6.6.3]
        case serviceUnavailable =               503 // [RFC7231, Section 6.6.4]
        case gatewayTimeout =                   504 // [RFC7231, Section 6.6.5]
        case httpVersionNotSupported =          505 // [RFC7231, Section 6.6.6]
        case variantAlsoNegotiates =            506 // [RFC2295]
        case insufficientStorage =              507 // [RFC4918]
        case loopDetected =                     508 // [RFC5842]
        case notExtended =                      510 // [RFC2774]
        case networkAuthenticationRequired =    511 // [RFC6585]
    }
}
