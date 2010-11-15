//
//  TimelineView.m
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "EventView.h"
#import "StateManager.h"

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
    // NSString *displayString = [NSString stringWithFormat:@"%@ %d", self.event.timestamp, self.event.type];    
    
    // Basic structure (in my disease addled state, at least) will be an icon specific to each 
    // event type. That'll be a 16x16 icon, 4.5 in from the edge. For now, we'll just draw a box
    // there. To the right of that we'll have a nice string format saying what happened.
    
    StateManager *state = [StateManager sharedInstance];
    
    NSString *displayString;
    switch (event.type) {
        case kUSER_JOINED_LOCATION:
            break;
        case kUSER_LEFT_LOCATION:
            break;
        case kUPDATE_TOPIC:
            break;
        case kNEW_TASK:
            break;
        case kASSIGN_TASK:

            if([((NSNumber *)[event.params objectForKey:@"deassign"]) intValue] == 1) {
                Actor *assignedBy = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
                displayString = [NSString stringWithFormat:@"%@ deassigned task.", assignedBy.name];
            } else {
                Actor *assignedBy = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
                User *assignedTo = (User *)[state getObjWithUUID:[event.params objectForKey:@"assignedTo"] withType:[User class]];
                displayString = [NSString stringWithFormat:@"%@ assigned task to %@.", assignedBy.name, assignedTo.name];
            }
            break;
            
        case kNEW_TOPIC:
            // This is another one of those cases where I can't create new object variables on the first line
            // of a case statement. So bizarre. Adding an NSLog fixes things.
            NSLog(@"new topic event");
            Actor *createdBy = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
            displayString = [NSString stringWithFormat:@"%@ created new task.", createdBy.name];
            break;
    }
    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // icon placeholder.
    CGContextFillRect(ctx, CGRectMake(4.5, 4.5, 16, 16));
    
    
    [displayString drawInRect:CGRectMake(23, 2.5, self.frame.size.width, self.frame.size.height) withFont:[UIFont systemFontOfSize:12]];
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
