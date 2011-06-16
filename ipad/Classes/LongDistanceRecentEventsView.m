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
            

            [self performSelectorOnMainThread:@selector(flash:) withObject:nil waitUntilDone:false];
//            [self flash:nil];
//            NSLog(@"FLASHING! LONG!");
//            [UIView animateWithDuration:1.0 animations:^{
//                self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
//            } completion: ^(BOOL finished){
//                [UIView animateWithDuration:1.0 animations:^{
//                    self.backgroundColor = [UIColor blackColor];
//                }];
//            }];

            
            break;
        default:
            break;
    }    
}

- (void) flash:(id)sender {
    NSLog(@"FLASHING ON METHOD");
    [UIView animateWithDuration:1.0 animations:^{
        NSLog(@" <- FLASH START");
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    } completion: ^(BOOL finished){
        NSLog(@" -> FLASH COMPLETE");
        [UIView animateWithDuration:5.0 animations:^{
            self.backgroundColor = [UIColor blackColor];
        }];
    }];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // There are two general categories of representation - those that have text (ie are operating on 
    // tasks or topics and so have a direct object) and those that don't (basically, join/leave).
    NSString *label;
    Actor *actor = (Actor *)[[StateManager sharedInstance] getObjWithUUID:mostRecentEvent.actorUUID withType:[Actor class]];
    
    UIFont *nameFont = [UIFont boldSystemFontOfSize:85];
    UIFont *labelFont = [UIFont boldSystemFontOfSize:52];
    
    CGSize nameSize = [actor.name sizeWithFont:nameFont constrainedToSize:CGSizeMake(685, 260) lineBreakMode:UILineBreakModeTailTruncation];
    
    CGSize labelSize;
    
    NSString *text;
    Topic *topic;
    Task *task;
    float ageFraction;
    
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

            // Over 3 minutes fade to 0.6 from 1.0.
            
            ageFraction = abs([mostRecentEvent.timestamp timeIntervalSinceNow])/180.0;
            
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.6+0.4*(1-ageFraction) alpha:1.0].CGColor);

            
            [actor.name drawInRect:CGRectMake(5, 5, nameSize.width, nameSize.height) withFont:nameFont];
            
            labelSize = [label sizeWithFont:labelFont constrainedToSize:CGSizeMake(934-nameSize.width, INT_MAX)];
                        
            [label drawInRect:CGRectMake(5+nameSize.width + 15, 5 + 50-labelSize.height/2, labelSize.width, labelSize.height) withFont:labelFont];
            
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
                    
                    UUID *topicUUID = ((Topic *)[mostRecentEvent.results objectForKey:@"topic"]).uuid;
                    NSLog(@"topicUUID: %@", topicUUID);
                    
                    topic = (Topic *)[[StateManager sharedInstance] getObjWithUUID:topicUUID withType:[Topic class]];
                    
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
                    
                    task = (Task *)[[StateManager sharedInstance] getObjWithUUID:[mostRecentEvent.params objectForKey:@"taskUUID"] withType:[Task class]];
                    text = task.text;
                    
                    break;
                case kNEW_TASK:
                    label = @"created task";
                    
                    task = [mostRecentEvent.results objectForKey:@"task"];

                    
                    text = task.text;
                    break;
            }
                      
            
            // Over 3 minutes fade to 0.6 from 1.0.
            ageFraction = abs([mostRecentEvent.timestamp timeIntervalSinceNow])/180.0;
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.6+0.4*(1-ageFraction) alpha:1.0].CGColor);
            
            [actor.name drawInRect:CGRectMake(5, 5, nameSize.width, nameSize.height) withFont:nameFont];
            
            // With the label, we want a minimum width of 115, but allow it to be bigger if space permits. 
            // The minimum will be enforced by the constraint on the name rect.
            
            // Gotta do a bit of a dance here - if it's going to fit on one line, it needs to have a different
            // origin.            
            labelSize = [label sizeWithFont:labelFont constrainedToSize:CGSizeMake(934-nameSize.width, INT_MAX)];
            
            [label drawInRect:CGRectMake(5+nameSize.width + 15, 5 + 50-labelSize.height/2, labelSize.width, labelSize.height) withFont:labelFont];

            
            NSLog(@"about to draw text: %@", text);
            [text drawInRect:CGRectMake(5, nameSize.height+10, 915, 120) withFont:labelFont];
            
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
