//
//  NSDate+TimeSince.m
//  shared-utils
//
//  Created by Andrew McKnight on 10/2/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

#import "NSDate+TimeSince.h"
#import "NSDate+DateComponents.h"

@implementation NSDate (TimeSince)

- (NSString *)durationStringSinceDate:(NSDate *)date {
    if ([self compare:date] == NSOrderedSame) {
        return @"No elapsed time";
    }

    NSDateComponents *firstDC = [date dateComponents];
    NSDateComponents *secondDC = [self dateComponents];

    //calculate varying length time representations of the duration
    int totalYears = [self timeIntervalSinceDate:date] / (60 * 60 * 24 * 364.25);
    int totalMonths = [self timeIntervalSinceDate:date] / (60 * 60 * 24 * 30);
    int remMonths = totalMonths % 12;
    int totalDays = [self timeIntervalSinceDate:date] / (60 * 60 * 24);
    int remDays = totalDays % 30;
    int totalHours = [self timeIntervalSinceDate:date] / (60 * 60);
    int remHours = totalHours % 24;
    int totalMinutes = [self timeIntervalSinceDate:date] / 60;
    int remMinutes = totalMinutes % 60;

    //display the duration with reasonable representations (e.g. if monthslong, display in months/days and not minutes/seconds)
    BOOL sameYear = secondDC.year == firstDC.year;
    BOOL sameMonth = secondDC.month == firstDC.month;
    BOOL sameDay = secondDC.day == firstDC.day;
    BOOL sameHour = secondDC.hour == firstDC.hour;
    BOOL sameMinute = secondDC.minute == firstDC.minute;

    if (sameMinute) {
        return @"< 1 minute";
    }

    BOOL differAtMostByMinute = sameYear && sameMonth && sameDay && sameHour && secondDC.minute != firstDC.minute;
    BOOL differAtMostByHours = sameYear && sameMonth && sameDay && secondDC.hour != firstDC.hour;
    BOOL differAtMostByDays = sameYear && sameMonth && secondDC.day != firstDC.day;
    BOOL differAtMostByMonths = sameYear && secondDC.month != firstDC.month;

    return [NSString stringWithFormat:@"%@",
            differAtMostByMinute ?
                /*minutes*/ [NSString stringWithFormat:@"%i minute%@", totalMinutes, totalMinutes == 1 ? @"" : @"s"]
                : differAtMostByHours ?
                    /*hours and minutes*/ [NSString stringWithFormat:@"%i hour%@, %i minute%@", totalHours, totalHours == 1 ? @"" : @"s", remMinutes, remMinutes == 1 ? @"" : @"s"]
                : differAtMostByDays ?
                    /*days, hours(as decimal)*/ [NSString stringWithFormat:@"%i day%@, %.2f hour%@", totalDays, totalDays == 1 ? @"" : @"s", remHours + (remMinutes) / 60.0, (remHours + (remMinutes) / 60.0) == 1 ? @"" : @"s"]
                : differAtMostByMonths ?
                    /*months and days (decimal)*/ [NSString stringWithFormat:@"%i month%@, %.2f day%@", totalMonths, totalMonths == 1 ? @"" : @"s", remDays + (remHours) / 24.0 + (remMinutes) / (60.0 * 24.0), (remDays + (remHours) / 24.0 + (remMinutes) / (60.0 * 24.0)) == 1 ? @"" : @"s"]
                :
                    /*years and months (decimal)*/ [NSString stringWithFormat:@"%i year%@, %.2f month%@", totalYears, totalYears == 1 ? @"" : @"s", remMonths + (remDays) / 30.0 + (remHours) / (24.0 * 30.0) + (remMinutes) / (60.0 * 24.0 * 30.0), (remMonths + (remDays) / 30.0 + (remHours) / (24.0 * 30.0) + (remMinutes) / (60.0 * 24.0 * 30.0)) == 1 ? @"" : @"s"] ];
}

@end
