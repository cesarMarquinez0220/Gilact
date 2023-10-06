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

#import "FLTBetterPlayerPlugin.h"

FOUNDATION_EXPORT double better_playerVersionNumber;
FOUNDATION_EXPORT const unsigned char better_playerVersionString[];

