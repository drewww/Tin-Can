//
//  TimelineContainerView.h
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventContainerContentView.h"

@interface TimelineContainerView : UIView {

    UIScrollView *scrollView;
    EventContainerContentView *eventContentView;
    
}


- (void) addEventView:(UIView *)eventView;

@end
