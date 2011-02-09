//
//  TimelineView.m
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "EventView.h"
#import "StateManager.h"

#import "Topic.h"
#import "User.h"
#import "Actor.h"
#import "Location.h"
#import "Task.h"
#import "NSString+Util.h"

@implementation EventView

@synthesize event;

- (id)initWithFrame:(CGRect)frame withEvent:(Event *)theEvent {
    if ((self = [super initWithFrame:frame])) {
        
        // Adapting this from LocationView; this will be something else. Events, probably.
        // self.location = theLocation;
        self.event = theEvent;
        
		self.frame=frame;
		self.alpha = 0;
        
        
        // Set the background color to the color of the location of the actor.
        Actor *actor = (Actor *)[[StateManager sharedInstance] getObjWithUUID:self.event.actorUUID withType:[Actor class]];
        
        // If it's a user, we need to get the location. If it's a location, we can ask it directly.
        if([actor isKindOfClass:[User class]]) {
            User *user = (User *)actor;
            self.backgroundColor = user.location.color;
        } else {
            Location *location = (Location *)actor;
            self.backgroundColor = location.color;
        }
     
        // Basic structure (in my disease addled state, at least) will be an icon specific to each 
        // event type. That'll be a 16x16 icon, 4.5 in from the edge. For now, we'll just draw a box
        // there. To the right of that we'll have a nice string format saying what happened.
        
        StateManager *state = [StateManager sharedInstance];
        
        displayString = @"Placeholder display string.";
        displayImage = [UIImage imageNamed:@"error.png"];

        Location *location;
        User *user;
        Task *task;
        Topic *topic;

        switch (event.type) {
            case kUSER_JOINED_LOCATION:
                
                location = (Location *)[state getObjWithUUID:[event.params objectForKey:@"location"]
                                                    withType:[Location class]];
                
                user = (User *)[state getObjWithUUID:event.actorUUID withType:[User class]];
                displayString = [NSString stringWithFormat:@"%@ joined %@.", user.name, location.name];
                displayImage = [UIImage imageNamed:@"user_add.png"];
                break;
            case kUSER_LEFT_LOCATION:
                location = (Location *)[state getObjWithUUID:[event.params objectForKey:@"location"]
                                                    withType:[Location class]];
                
                user = (User *)[state getObjWithUUID:event.actorUUID withType:[User class]];
                displayString = [NSString stringWithFormat:@"%@ left %@.", user.name, location.name];
                displayImage = [UIImage imageNamed:@"user_delete.png"];
                break;
            case kUPDATE_TOPIC:
                actor = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
                topic = (Topic *)[state getObjWithUUID:[event.params objectForKey:@"topicUUID"] withType:[Topic class]];
                
                NSString *status = [event.params objectForKey:@"status"];
                
                if ([status isEqualToString:@"CURRENT"]) {
                    displayString = [NSString stringWithFormat:@"%@ started topic: \"%@\"", actor.name, [topic.text excerptBeyondLength:15]];
                } else if ([status isEqualToString:@"PAST"]) {
                    displayString = [NSString stringWithFormat:@"%@ stopped topic: \"%@\"", actor.name, [topic.text excerptBeyondLength:15]];                
                } 

                displayImage = [UIImage imageNamed:@"time_go.png"];
                
                break;
            case kNEW_TASK:
                actor = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
                task = [event.results objectForKey:@"task"];
                displayString = [NSString stringWithFormat:@"%@ added idea \"%@\"", actor.name, [task.text excerptBeyondLength:15]];
                displayImage = [UIImage imageNamed:@"note_add.png"];
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
                
                displayImage = [UIImage imageNamed:@"note_go.png"];

                
                break;
                
            case kNEW_TOPIC:
                // This is another one of those cases where I can't create new object variables on the first line
                // of a case statement. So bizarre. Adding an NSLog fixes things.
                topic = [event.results objectForKey:@"topic"];
                
                actor = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
                displayString = [NSString stringWithFormat:@"%@ created new topic: \"%@\"", actor.name, [topic.text excerptBeyondLength:15]];
                displayImage = [UIImage imageNamed:@"time_add.png"];
                break;
            default:
                displayString = @"Drawing un-handled event type.";
                displayImage = [UIImage imageNamed:@"error.png"];
                break;
        }
       
        // Now add the display image as a subview.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:displayImage];
        imageView.frame = CGRectMake(4.5, 4.5, 16, 16);
        [self addSubview:imageView];
        
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
		
		self.alpha = 1.0;
		
		[UIView commitAnimations];
		
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // icon placeholder.
//    CGContextFillRect(ctx, CGRectMake(4.5, 4.5, 16, 16));
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    [displayString drawInRect:CGRectMake(23, 2.5, self.frame.size.width, self.frame.size.height) withFont:[UIFont systemFontOfSize:12]];
}

- (NSComparisonResult) compareByTime:(EventView *)view {
    
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
