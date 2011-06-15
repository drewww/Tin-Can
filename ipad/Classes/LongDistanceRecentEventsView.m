//
//  LongDistanceRecentEventsView.m
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LongDistanceRecentEventsView.h"
#import "StateManager.h"
#import "Actor.h"
#import "Task.h"
#import "Topic.h"

// Shows the most recent event (or two) that have happened
// in the meeting.
@implementation LongDistanceRecentEventsView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 399, 934, 279)];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}



// The first pass will be to just to draw based on the most recent event.

- (void)newEvent:(Event *)newEvent {
    NSLog(@"GOT A NEW EVENT: %@", newEvent);
    switch(newEvent.type) {
        case kUSER_JOINED_LOCATION:
        case kUSER_LEFT_LOCATION:
        case kUPDATE_TOPIC:
        case kNEW_TOPIC:
        case kNEW_TASK:
        case kASSIGN_TASK:
            NSLog(@"Grabbing that event for future redrawing.");
            [mostRecentEvent release];
            mostRecentEvent = newEvent;
            [mostRecentEvent retain];
            [self setNeedsDisplay];
            break;
        default:
            break;
    }    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawing RecentEventView!");
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // There are two general categories of representation - those that have text (ie are operating on 
    // tasks or topics and so have a direct object) and those that don't (basically, join/leave).
    NSString *label;
    Actor *actor = (Actor *)[[StateManager sharedInstance] getObjWithUUID:mostRecentEvent.actorUUID withType:[Actor class]];
    
    UIFont *nameFont = [UIFont boldSystemFontOfSize:85];
    UIFont *labelFont = [UIFont boldSystemFontOfSize:52];
    
    CGSize nameSize = [actor.name sizeWithFont:nameFont constrainedToSize:CGSizeMake(685, 260) lineBreakMode:UILineBreakModeTailTruncation];
    
    NSString *text;
    Topic *topic;
    Task *task;
    
    if(mostRecentEvent == nil) {
        // Do nothing, for now.
        return;
    }
    
    switch(mostRecentEvent.type) {
        case kUSER_JOINED_LOCATION:
        case kUSER_LEFT_LOCATION:
            if(mostRecentEvent.type==kUSER_JOINED_LOCATION)
                label = @"joined meeting";
            else
                label = @"left meeting";

            [actor.name drawInRect:CGRectMake(5, 5, nameSize.width, nameSize.height) withFont:nameFont];
            [label drawInRect:CGRectMake(5+nameSize.width + 2, 5, 220, 115) withFont:labelFont];
            break;
            
        case kUPDATE_TOPIC:
        case kNEW_TOPIC:
        case kNEW_TASK:
        case kASSIGN_TASK:
            
            switch(mostRecentEvent.type) {
                case kUPDATE_TOPIC:
                    NSLog(@"Stupid case statement bug.");
                    
                    NSString *status = [mostRecentEvent.params objectForKey:@"status"];
                    
                    if([status isEqualToString:@"CURRENT"]) {
                        label = @"started topic";
                    } else if ([status isEqualToString:@"PAST"]) {
                        label = @"stopped topic";
                    }
                    
                    topic = (Topic *)[[StateManager sharedInstance] getObjWithUUID:[mostRecentEvent.params objectForKey:@"topicUUID"] withType:[Topic class]];
                    
                    text = topic.text;
                    
                    break;
                case kNEW_TOPIC:
                    label = @"created topic";
                    
                    topic = (Topic *)[[StateManager sharedInstance] getObjWithUUID:[mostRecentEvent.params objectForKey:@"topicUUID"] withType:[Topic class]];
                    
                    text = topic.text;
                    
                    break;
                case kASSIGN_TASK:
                    if([((NSNumber *)[mostRecentEvent.params objectForKey:@"deassign"]) intValue] == 1) {
                        label = @"deassigned task";
                    }
                    
                    User *assignedTo = (User *)[[StateManager sharedInstance] getObjWithUUID:[mostRecentEvent.params objectForKey:@"assignedTo"] withType:[User class]];
                    
                    if(assignedTo.uuid == actor.uuid) {
                        label = @"claimed task";
                    } else {
                        label = @"assigned task";
                    }
                    
                    task = [mostRecentEvent.results objectForKey:@"task"];
                    text = task.text;
                    
                    break;
                case kNEW_TASK:
                    label = @"created task";
                    
                    task = [mostRecentEvent.results objectForKey:@"task"];

                    
                    text = task.text;
                    break;
                    
            }
                        
            [actor.name drawInRect:CGRectMake(5, 5, nameSize.width, nameSize.height) withFont:nameFont];
            [label drawInRect:CGRectMake(5+nameSize.width + 2, 5, 220, 115) withFont:labelFont];

            [text drawInRect:CGRectMake(5, nameSize.height+5, 270, 120) withFont:labelFont];
            
            break;
             
        default:
             break;
             
    }
                   

                   
    
    // be caerful on assign task - distinguish between assignment and claiming (eg assignee and assigner checking)
}


- (void)dealloc
{
    [super dealloc];
}

@end
