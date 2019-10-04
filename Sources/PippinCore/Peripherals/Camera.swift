//
//  Camera.swift
//  PippinCore
//
//  Created by Andrew McKnight on 10/2/19.
//

import Foundation

/// Image data encoding formats.
public enum ImageEncoding {
    case png
    case jpg
}

/// Describes a container that holds data describing an image.
public protocol Image {
    /// The encoding of this image.
    var encoding: ImageEncoding { get }

    /// The raw image data.
    var data: Data { get }
}

/// Common functions and properties of a camera.

public protocol Camera {
    func takePhoto() -> Image
    var fieldOfView: (Double, Double) { get }
}
