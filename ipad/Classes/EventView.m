//
//  TimelineView.m
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "EventView.h"


@implementation EventView

@synthesize event;

- (id)initWithFrame:(CGRect)frame withEvent:(Event *)theEvent {
    if ((self = [super initWithFrame:frame])) {
        
        // Adapting this from LocationView; this will be something else. Events, probably.
        // self.location = theLocation;
        self.event = theEvent;
        
		self.frame=frame;
		self.alpha = 0;
        
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
		
		self.alpha = 1.0;
		
		
		[UIView commitAnimations];
		
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // For now, just print some random stuff to show that it's working.
    NSString *displayString = [NSString stringWithFormat:@"%@ %d", self.event.timestamp, self.event.type];    
    
    [displayString drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withFont:[UIFont systemFontOfSize:12]];
}

- (NSComparisonResult) compareByTime:(EventView *)view {
    
    NSLog(@"comparing by time");
    
    // I think there might be a way to do that key compare thing, but it's not as simple
    // as getting a key, so I'm not sure. Doing it this way which I know works, for now
    // at least.
    NSComparisonResult retVal = [self.event.timestamp compare:view.event.timestamp];
        
    return retVal;
}


- (void)dealloc {
    [super dealloc];
}


@end
