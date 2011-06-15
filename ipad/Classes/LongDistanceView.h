//
//  LongDistanceView.h
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LongDistanceStatusBarView.h"
#import "LongDistanceRecentEventsView.h"
#import "LongDistanceCurrentTopicView.h"

@interface LongDistanceView : UIView {

    LongDistanceStatusBarView *statusBar;
    LongDistanceCurrentTopicView *topic;
    LongDistanceRecentEventsView *recentEvents;
    
}

- (void) clk;
- (void) handleConnectionEvent:(Event *)event;

@end
