//
//  Fonts.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/13/17.
//

import UIKit

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
