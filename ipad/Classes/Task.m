//
//  Task.m
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Task.h"
#import "TaskView.h"

@implementation Task

@synthesize text;
@synthesize assignedTo;
@synthesize assignedBy;
@synthesize assignedAt;
@synthesize color;
@synthesize shared;

- (id) initWithUUID:(UUID *)myUUID
    withCreatorUUID:(UUID *)myCreatorUUID
          createdAt:(NSDate *)myCreatedAt
    withMeetingUUID:(UUID *)myMeetingUUID 
           withText:(NSString *)myText
     assignedToUUID:(UUID *)myAssignedToUUID
     assignedByUUID:(UUID *)myAssignedByUUID
         assignedAt:(NSDate *)myAssignedAt
          withColor:(UIColor *)myColor
{
    self = [super initWithUUID:myUUID withCreatorUUID:myCreatorUUID withMeetingUUID:myMeetingUUID
                     createdAt:myCreatedAt];
    
    self.text = myText;
    assignedToUUID = myAssignedToUUID;
    assignedByUUID = myAssignedByUUID;
    self.assignedAt = myAssignedAt;
    
    // Give it a default gray color if there's some issue with color assignment.
    if(myColor == nil) {
        myColor = [UIColor colorWithWhite:0.5 alpha:1];
    }
    self.color = myColor;
    
    self.shared = NO;
    
    return self;
}

- (bool) isAssigned {
    return assignedTo != nil && ![assignedTo isKindOfClass:[NSNull class]];
}


- (void) startAssignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime {
    NSLog(@"starting task assignment to user in Task object");
    
    // It's a bit annoying to have to pass all this stuff through the whole chain, but I'm not
    // sure how else to get it back, other than some kind of closure trick.
    [(TaskView *)view startAssignToUser:toUser byActor:byActor atTime:assignTime];
    
//    [UIView beginAnimations:nil context:nil];
//    
//    view.alpha = 0.0;
//    [UIView commitAnimations];
}


- (void) assignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime{
    NSLog(@"assigning task to user: %@", toUser);
    
    if(self.assignedTo != nil) {
        // deassign it. This is different from the deassign call because this is for transfers,
        // while that call is for being assigned to nothing (ie back to the unassigned pool)
        // There may be a better abstraction for this.
        [self.assignedTo removeTask:self];
    }
    
    self.assignedAt = assignTime;
    self.assignedBy = byActor;
    self.assignedTo = toUser;
    
    
    
        
    [self.assignedTo assignTask:self];
}

- (void) deleteTask {
    // A few steps. First, remove the task from the person it's assigned to.
    
    if(self.assignedTo != nil) {
        [self.assignedTo removeTask:self];
    }
    
    [view removeFromSuperview];    
}

- (void) startDeassignByActor:(Actor *)byActor atTime:(NSDate *)deassignTime withTaskContainer:(UIView *)taskContainer {
    [(TaskView *)view startDeassignByActor:byActor atTime:deassignTime withTaskContainer:taskContainer];   
}


- (void) deassignByActor:(Actor *)byActor atTime:(NSDate *)deassignTime{
    if(self.assignedTo != nil) {
        self.assignedBy = byActor;
        self.assignedAt = deassignTime;

        [self.assignedTo removeTask:self];
        self.assignedTo = nil;
    }
}

- (void) unswizzle {
    [super unswizzle];                                                            
    
    if(assignedToUUID!=nil && ![assignedToUUID isKindOfClass:[NSNull class]]) {
        self.assignedTo = (User *)[[StateManager sharedInstance] getObjWithUUID:assignedToUUID
                                                                        withType:[User class]];
        [self.assignedTo assignTask:self];
    }
    
    if(assignedByUUID!=nil && ![assignedByUUID isKindOfClass:[NSNull class]]) {
        self.assignedBy = (Actor *)[[StateManager sharedInstance] getObjWithUUID:assignedByUUID
                                                                       withType:[Actor class]];
    }
    NSLog(@"NEW TASK AFTER UNSWIZZLE. CREATED BY: %@, ASSIGNED BY: %@", self.creator, self.assignedBy);
    [self.meeting addTask:self];
}

- (NSString *)description {
    if(self.assignedTo != nil) { 
        return [NSString stringWithFormat:@"[task.%@ %@ for:%@ by:%@]", [self.uuid substringToIndex:6],
                self.text, self.assignedTo.name, self.assignedBy.name];
    }
    else
        return [NSString stringWithFormat:@"[task.%@ %@ for:null by:null]", [self.uuid substringToIndex:6],
                self.text];
}

- (UIView *)getView {
    
    if(view==nil) {
        // construct a new TaskView
        view = [[TaskView alloc] initWithTask:self];
    }
    
    // return the current view
    return view;
}

@end
