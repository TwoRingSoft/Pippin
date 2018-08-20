//
//  Fonts.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/13/17.
//

import UIKit

/// Protocol providing names/accessors for some standard variations of text displayed in an app.
public protocol Fonts {
    var superhero: UIFont { get }
    var hero: UIFont { get }

    var title: UIFont { get }
    var subtitle: UIFont { get }

    var header: UIFont { get }
    var subheader: UIFont { get }

    var text: UIFont { get }
    var italic: UIFont { get }
    var bold: UIFont { get }

    var barButtonTitle: UIFont { get }
    var tabBarItemTitle: UIFont { get }
}

/// Default implementation of a `struct` conforming to `Fonts`.
public struct DefaultFonts: Fonts {
    public init() {}
    
    public var superhero: UIFont { return UIFont.systemFont(ofSize: 60, weight: .regular) }
    public var hero: UIFont { return UIFont.systemFont(ofSize: 45, weight: .regular) }

    public var title: UIFont { return UIFont.systemFont(ofSize: 34, weight: .regular) }
    public var subtitle: UIFont { return UIFont.systemFont(ofSize: 28, weight: .regular) }

    public var header: UIFont { return UIFont.systemFont(ofSize: 24, weight: .bold) }
    public var subheader: UIFont { return UIFont.italicSystemFont(ofSize: 19) }

    public var text: UIFont { return UIFont.systemFont(ofSize: 17, weight: .regular) }
    public var italic: UIFont { return UIFont.italicSystemFont(ofSize: 17) }
    public var bold: UIFont { return UIFont.systemFont(ofSize: 17, weight: .bold) }

    public var barButtonTitle: UIFont { return UIFont.systemFont(ofSize: 20, weight: .regular) }
    public var tabBarItemTitle: UIFont { return UIFont.systemFont(ofSize: 11, weight: .regular) }
}
