//
//  UIColor+Util.h
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (Util)

- (UIColor *)colorDarkenedByPercent:(CGFloat)percent;
- (UIColor *)colorByChangingAlphaTo:(CGFloat)newAlpha;
- (NSString *)toHexString;

+ (UIColor *)colorForIndex:(NSInteger)index;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
@end
