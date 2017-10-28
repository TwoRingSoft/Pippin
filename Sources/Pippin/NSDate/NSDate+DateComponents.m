//
//  NSDate+DateComponents.m
//  Pippin
//
//  Created by Andrew McKnight on 10/2/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

#import "NSDate+DateComponents.h"

@implementation NSDate (DateComponents)

- (NSDateComponents *)dateComponents {
    return [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self];
}

- (NSDateComponents *)dayMonthYearComponents {
    return [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self];
}

@end
