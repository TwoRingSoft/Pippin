//
//  AuthorizedAVCaptureDevice.swift
//  CanIHaz
//
//  Created by Andrew McKnight on 4/18/16.
//  Copyright © 2019 Two Ring Software. All rights reserved.
//

import AVFoundation
import Foundation

public enum MediaType {
    case video
    case audio
    case text
    case closedCaption
    case subtitle
    case timecode
    case metadata
    case muxed

    func stringConstant() -> AVMediaType {
        switch(self) {
        case .audio:
            return AVMediaType.audio
        case .video:
            return AVMediaType.video
        case .text:
            return AVMediaType.text
        case .closedCaption:
            return AVMediaType.closedCaption
        case .subtitle:
            return AVMediaType.subtitle
        case .timecode:
            return AVMediaType.timecode
        case .metadata:
            return AVMediaType.metadata
        case .muxed:
            return AVMediaType.muxed
        }
    }
}

private let CaptureDeviceAuthorizationErrorDomain = "com.tworingsoft.authorized-capture-device.error"

private enum CaptureDeviceAuthorizationErrorCode: Int {
    case denied
    case couldNotCreate
}

public typealias CaptureDeviceAuthorizationResult = Result<AVCaptureDevice, NSError>
public typealias CaptureDeviceAuthorizationCompletionBlock = ((CaptureDeviceAuthorizationResult) -> Void)

public final class AuthorizedAVCaptureDevice: NSObject {

    public class func authorizedCaptureDevice(_ mediaType: MediaType, completion: CaptureDeviceAuthorizationCompletionBlock?) {

        #if targetEnvironment(simulator)
        completion?(.failure(NSError(domain: CaptureDeviceAuthorizationErrorDomain, code: CaptureDeviceAuthorizationErrorCode.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Capture device not available on iOS Simulator."])))
            return
        #else
            if currentlyAuthorized(forMediaType: mediaType) {
                completion?(.success(createCaptureDevice(mediaType)))
                return
            }

            checkRequiredPlistValues()
            requestAccess(mediaType: mediaType, completion: completion)
        #endif
    }

}

fileprivate extension AuthorizedAVCaptureDevice {

    class func currentlyAuthorized(forMediaType mediaType: MediaType) -> Bool {
        var authorized = false
        let status = AVCaptureDevice.authorizationStatus(for: mediaType.stringConstant())
        switch status {
        case .authorized:
            authorized = true
            break
        case .denied:
            authorized = false
            break
        case .notDetermined:
            authorized = false
            break
        case .restricted:
            authorized = false
            break
        @unknown default:
            fatalError("New unexpected authorization status encountered: \(status)")
        }

        return authorized
    }

    class func requestAccess(mediaType: MediaType, completion: CaptureDeviceAuthorizationCompletionBlock?) {
        AVCaptureDevice.requestAccess(for: mediaType.stringConstant()) { authorizationGranted in
            if !authorizationGranted {
                let authorizationError: NSError? = NSError(domain: CaptureDeviceAuthorizationErrorDomain, code: CaptureDeviceAuthorizationErrorCode.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Capture device for media type \(mediaType.stringConstant()) not available.", NSLocalizedFailureReasonErrorKey: "The user denied the request to access \(mediaType.stringConstant())."])
                completion?(.failure(authorizationError))
                return
            }

            guard let device = createCaptureDevice(mediaType) else {
                let creationError: NSError? = NSError(domain: CaptureDeviceAuthorizationErrorDomain, code: CaptureDeviceAuthorizationErrorCode.couldNotCreate.rawValue, userInfo: [NSLocalizedDescriptionKey: "Capture device for media type \(mediaType.stringConstant()) not available.", NSLocalizedFailureReasonErrorKey: "The user denied the request to access \(mediaType.stringConstant())."])
                completion?(.failure(creationError))
            }

            completion?()
        }
    }

    class func checkRequiredPlistValues() {
        let requiredPlistKey = "NSCameraUsageDescription"

        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Could not locate Info.plist keys and values.")
        }
        guard let requiredCameraRequestDescriptionValue = infoDictionary[requiredPlistKey] as? String else {
            fatalError("You must provide a value for \(requiredPlistKey) in your app's Info.plist for the camera access request dialog to be shown to the user.")
        }
        if requiredCameraRequestDescriptionValue.count == 0 {
            fatalError("You provided a description value for \(requiredPlistKey) with length 0. This string is displayed to the user in the request prompt; consider providing more information why you are requesting location services.")
        }
    }

    class func createCaptureDevice(_ mediaType: MediaType) -> AVCaptureDevice? {
        return AVCaptureDevice.default(for: mediaType.stringConstant())
    }

}

