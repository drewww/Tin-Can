//
//  TaskDropTarget.h
//  TinCan
//
//  Created by Drew Harry on 9/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskDropTarget
- (void) setHoverState:(bool)state;
@end