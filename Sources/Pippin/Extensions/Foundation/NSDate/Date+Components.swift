//
//  Date+Components.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/26/18.
//

import Foundation

public extension Date {
    func dateComponents() -> DateComponents {
        return Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year, .hour, .minute), from: self)
    }
    
    func dayMonthYearComponents() -> DateComponents {
        return Calendar.current.dateComponents(Set<Calendar.Component>(arrayLiteral: .day, .month, .year, .hour, .minute), from: self)
    }
}
