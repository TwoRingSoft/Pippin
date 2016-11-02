//
//  NSDate+TimeSince.h
//  shared-utils
//
//  Created by Andrew McKnight on 10/2/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//



@interface NSDate (TimeSince)
NS_ASSUME_NONNULL_BEGIN
- (NSString *)durationStringSinceDate:(NSDate *)date;
OS_ASSUME_NONNULL_END
@end
