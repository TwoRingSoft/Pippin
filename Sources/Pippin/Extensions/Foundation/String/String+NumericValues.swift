//
//  String+NumericValues.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/18/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

public extension String {

    func isAllDigits() -> Bool {
        if self.count == 0 {
            return false
        }

        let nondecimalDigitSet = NSCharacterSet.decimalDigits.inverted

        let nondecimalCharacters = self.filter { char in
            let str = String(char)
            guard let uni = UnicodeScalar(str) else { return false }
            return nondecimalDigitSet.contains(uni)
        }

        return nondecimalCharacters.count == 0
    }

    var doubleValue: Double {
        return (self as NSString).doubleValue
    }

    var intValue: Int32 {
        return (self as NSString).intValue
    }
    
    var integerValue: Int {
        return (self as NSString).integerValue
    }

    /// 0 if no unsigned integer exists.
    var unsignedIntegerValue: UInt {
        var value: UInt64 = 0
        let scanner = Scanner(string: self)
        if scanner.scanUnsignedLongLong(&value) {
            if value == UInt64(ULLONG_MAX) {
                print(String(format: "[%@] could not extract unsigned integer from %@ due to overflow.", instanceType(self as NSObject), self))
            }

            return UInt(value)
        } else {
            print(String(format: "[%@] could not extract unsigned integer from %@.", instanceType(self as NSObject), self))
            return 0
        }

    }

}
