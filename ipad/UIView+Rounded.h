//
//  UIView+Rounded.h
//  TinCan
//
//  Created by Drew Harry on 2/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Rounded) 
    - (void) fillRoundedRect:(CGRect)boundingRect withRadius:(CGFloat)radius withRoundedBottom:(bool)roundedBottom;
@end
