//
//  TimelineView.h
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventView : UIView {
    Event *event;
    
    NSString *displayString;
    UIImage *displayImage;
}

- (id)initWithFrame:(CGRect)frame withEvent:(Event *)theEvent;

- (NSComparisonResult) compareByTime:(EventView *)view;

@property (nonatomic, retain) Event *event;

@end
