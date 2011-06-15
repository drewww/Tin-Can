//
//  LongDistanceRecentEventsView.h
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface LongDistanceRecentEventsView : UIView {
    Event *mostRecentEvent;
}

- (void)newEvent:(Event *)newEvent;
- (void) flash:(id)sender;

@end
