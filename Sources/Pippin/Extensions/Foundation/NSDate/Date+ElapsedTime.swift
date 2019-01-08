//
//  Date+ElapsedTime.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/26/18.
//

import Foundation

let secondsInYear: TimeInterval = secondsInDay * daysInYear
let secondsInMonth: TimeInterval = secondsInDay * daysInMonth
let secondsInDay: TimeInterval = secondsInHour * hoursInDay
let secondsInHour: TimeInterval = 60 * minutesInHour
let secondsInMinute: TimeInterval = 60

let minutesInHour: TimeInterval = 60
let minutesInDay: TimeInterval = minutesInHour * hoursInDay
let minutesInMonth: TimeInterval = minutesInHour * hoursInMonth
let minutesInYear: TimeInterval = daysInYear * minutesInDay

let hoursInDay: TimeInterval = 24
let hoursInMonth: TimeInterval = hoursInDay * daysInMonth
let hoursInYear: TimeInterval = daysInYear * hoursInDay

let monthsInYear: TimeInterval = 12

let daysInMonth: TimeInterval = 30
let daysInYear: TimeInterval = 364.25

public extension Date {
    /// Compute a conversational description of a duration of time, using the largest unit possible. So, "3 years" instead of "1,095 days".
    ///
    /// - Parameter date: The date in the past where the duration starts.
    /// - Returns: A `String` containing a conversational description of the amount of time.
    func elapsedTime(since date: Date) -> String {
        if date.compare(self) == ComparisonResult.orderedSame {
            return "No elpased time"
        }
        
        let interval = self.timeIntervalSince(date)
        
        let totalMinutes = interval / secondsInMinute
        let remainingMinutes = fmod(totalMinutes, minutesInHour)
        guard totalMinutes >= 1 else {
            return String(
                format: "%.2f %@",
                interval,
                "second".pluralized(forValue: interval)
            )
        }
        
        let totalHours = interval / secondsInHour
        let remainingHours = fmod(totalHours, hoursInDay)
        guard totalHours >= 1 else {
            return String(
                format: "%i %@",
                Int(totalMinutes),
                "minute".pluralized(forValue: totalMinutes)
            )
        }
        
        let totalDays = interval / secondsInDay
        let remainingDays = fmod(totalDays, daysInMonth)
        guard totalDays >= 1 else {
            return String(
                format: "%i %@, %i %@",
                Int(totalHours),
                "hour".pluralized(forValue: totalHours),
                Int(remainingMinutes),
                "minute".pluralized(forValue: Int(remainingMinutes))
            )
        }
        
        let totalMonths = interval / secondsInMonth
        let remainingMonths = fmod(totalMonths, monthsInYear)
        guard totalMonths >= 1 else {
            let totalRemainingHours = remainingHours + remainingMinutes / minutesInHour
            return String(
                format: "%i %@, %.2f %@",
                Int(totalDays),
                "day".pluralized(forValue: totalDays),
                totalRemainingHours,
                "hour".pluralized(forValue: totalRemainingHours)
            )
        }
        
        let totalYears = interval / secondsInYear
        guard totalYears >= 1 else {
            let totalRemainingDays = remainingDays + remainingHours / hoursInDay + remainingMinutes / minutesInDay
            return String(
                format: "%i %@, %.2f %@",
                Int(totalMonths),
                "month".pluralized(forValue: totalMonths),
                totalRemainingDays,
                "day".pluralized(forValue: totalRemainingDays)
            )
        }
        
        let totalRemainingMonths = remainingMonths + remainingDays / daysInMonth + remainingHours / hoursInMonth + remainingMinutes + minutesInMonth
        return String(
            format: "%i %@, %.2f %@",
            Int(totalYears),
            "year".pluralized(forValue: totalYears),
            totalRemainingMonths,
            "month".pluralized(forValue: totalRemainingMonths)
        )
    }
}
