#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSDate+DateComponents.h"
#import "NSDate+TimeSince.h"

FOUNDATION_EXPORT double PippinVersionNumber;
FOUNDATION_EXPORT const unsigned char PippinVersionString[];

