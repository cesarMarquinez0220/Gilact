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

#import "FijkHostOption.h"
#import "FijkPlayer.h"
#import "FijkPlugin.h"
#import "FijkQueuingEventSink.h"

FOUNDATION_EXPORT double fijkplayerVersionNumber;
FOUNDATION_EXPORT const unsigned char fijkplayerVersionString[];

