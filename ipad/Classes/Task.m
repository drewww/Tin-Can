//
//  Task.m
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Task.h"

@implementation Task

@synthesize text;
@synthesize assignedTo;
@synthesize assignedBy;
@synthesize assignedAt;

- (id) initWithUUID:(UUID *)myUUID withCreatorUUID:(UUID *)myCreatorUUID createdAt:(NSDate *)myCreatedAt
    withMeetingUUID:(UUID *)myMeetingUUID 
           withText:(NSString *)myText
     assignedToUUID:(UUID *)myAssignedToUUID
     assignedByUUID:(UUID *)myAssignedByUUID
         assignedAt:(NSDate *)myAssignedAt
{
    self = [super initWithUUID:myUUID withCreatorUUID:myCreatorUUID withMeetingUUID:myMeetingUUID
                     createdAt:myCreatedAt];
    
    
    self.text = myText;
    assignedToUUID = myAssignedToUUID;
    assignedByUUID = myAssignedByUUID;
    self.assignedAt = myAssignedAt;
    
    return self;
}

- (void) assignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime{
    self.assignedAt = assignTime;
    self.assignedBy = byActor;
    self.assignedTo = toUser;
    
    [self.assignedTo assignTask:self];
}

- (void) deassignByActor:(Actor *)assignedBy atTime:(NSDate *)deassignTime{
    if(self.assignedTo != nil) {
        self.assignedBy = assignedBy;
        self.assignedAt = deassignTime;

        [self.assignedTo removeTask:self];
        self.assignedTo = nil;
    }
}


- (void) unswizzle {
    if(assignedToUUID!=nil && ![assignedToUUID isKindOfClass:[NSNull class]]) {
        self.assignedTo = (User *)[[StateManager sharedInstance] getObjWithUUID:assignedToUUID
                                                                        withType:[User class]];
    }
    
    if(assignedByUUID!=nil && ![assignedByUUID isKindOfClass:[NSNull class]]) {
        self.assignedBy = (Actor *)[[StateManager sharedInstance] getObjWithUUID:assignedByUUID
                                                                       withType:[Actor class]];
    }
    
    [self.meeting addTask:self];
}

@end
