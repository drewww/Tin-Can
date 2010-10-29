//
//  TimelineView.m
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "EventView.h"


@implementation EventView


- (id)initWithFrame:(CGRect)frame withEvent:(Event *)theEvent {
    if ((self = [super initWithFrame:frame])) {
        
        // Adapting this from LocationView; this will be something else. Events, probably.
        // self.location = theLocation;

		self.frame=frame;
		self.alpha = 0;
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
		
		self.alpha = 1.0;
		
		
		[UIView commitAnimations];
		
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (NSComparisonResult) compareByTime:(TimelineView *)view {
    
    // Tries to comare by strings, but if they end up being exactly the same string,
    // it will resolve the ties by comparing pointers. This is a deterministic comparison
    // and an arbitrary (but stable) way to tell between tasks with identical text.
    // This is a rare case in real use, but happens a lot in testing, so this gives us some
    // protection from bad issues during demoing.
//    NSComparisonResult retVal = [self.location.name compare:view.location.name];
//    
//    if(retVal==NSOrderedSame) {
//        if (self < view)
//            retVal = NSOrderedAscending;
//        else if (self > view) 
//            retVal = NSOrderedDescending;
//    }
    
    return NSOrderedSame;
}


- (void)dealloc {
    [super dealloc];
}


@end
