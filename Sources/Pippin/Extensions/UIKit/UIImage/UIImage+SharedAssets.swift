//
//  UIImage+SharedAssets.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/2/18.
//

import Foundation

private class UIImage_Shared_Asset_Bundle_Class: NSObject {}

extension UIImage {

    public convenience init?(sharedAssetName name: String) {
        self.init(named: name, in: Bundle(for: UIImage_Shared_Asset_Bundle_Class.self), compatibleWith: nil)
    }

}
