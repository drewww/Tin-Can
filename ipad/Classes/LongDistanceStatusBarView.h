//
//  LongDistanceStatusBarView.h
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LongDistanceStatusBarView : UIView {
    NSDate *curTime;
    NSDateFormatter *formatter;
}

- (void) clk;

@end
