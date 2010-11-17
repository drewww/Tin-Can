//
//  NSString+Util.m
//  TinCan
//
//  Created by Drew Harry on 11/17/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "NSString+Util.h"


@implementation NSString (Util)

// If the string is longer than the specified length, return a version shortened
// to the target length. Useful for UI situations when you have a limited amount
// of space and unpredictable input lenghts. Easier than using substringToIndex
// because if the string is less than that length, it automatically returns the
// string instead of throwing an error.
- (NSString *) excerptBeyondLength:(int)length {
    
    if([self length] > length) {
        return [NSString stringWithFormat:"%@%@", [self substringToIndex:length-3], @"..."];
    } else {
        return self;
    }
}

@end
