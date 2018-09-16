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
    func elapsedTime(since date: Date) -> String {
        if date.compare(self) == ComparisonResult.orderedSame {
            return "No elpased time"
        }
        
        let interval = self.timeIntervalSince(date)
        let totalYears = interval / secondsInYear
        let totalMonths = interval / secondsInMonth
        let remainingMonths = fmod(totalMonths, monthsInYear)
        let totalDays = interval / secondsInDay
        let remainingDays = fmod(totalDays, daysInMonth)
        let totalHours = interval / secondsInHour
        let remainingHours = fmod(totalHours, hoursInDay)
        let totalMinutes = interval / secondsInMinute
        let remainingMinutes = fmod(totalMinutes, minutesInHour)
        
        let differAtMostBySeconds = totalMinutes < 1
        let differAtMostByMinutes = totalHours < 1
        let differAtMostByHours = totalDays < 1
        let differAtMostByDays = totalMonths < 1
        let differAtMostByMonths = totalYears < 1
        
        guard !differAtMostBySeconds else {
            return String(
                format: "%.2f %@",
                interval,
                "second".pluralized(forValue: interval)
            )
        }

        guard !differAtMostByMinutes else {
            return String(
                format: "%i %@",
                Int(totalMinutes),
                "minute".pluralized(forValue: totalMinutes)
            )
        }
        guard !differAtMostByHours else {
            return String(
                format: "%i %@, %i %@",
                Int(totalHours),
                "hour".pluralized(forValue: totalHours),
                Int(remainingMinutes),
                "minute".pluralized(forValue: Int(remainingMinutes))
            )
        }
        guard !differAtMostByDays else {
            let totalRemainingHours = remainingHours + remainingMinutes / minutesInHour
            return String(
                format: "%i %@, %.2f %@",
                Int(totalDays),
                "day".pluralized(forValue: totalDays),
                totalRemainingHours,
                "hour".pluralized(forValue: totalRemainingHours)
            )
        }
        guard !differAtMostByMonths else {
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
