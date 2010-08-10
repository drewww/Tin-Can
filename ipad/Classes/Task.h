//
//  Task.h
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMeetingObject.h"
#import "User.h"
#import "Actor.h"
#import "StateManager.h"


@interface Task : BaseMeetingObject {

    NSString *text;
    UUID *assignedToUUID;
    UUID *assignedByUUID;
    
    User *assignedTo;
    Actor *assignedBy;
    
    NSDate *assignedAt;
    
    UIView *view;
}


- (id) initWithUUID:(UUID *)myUUID withCreatorUUID:(UUID *)myCreatorUUID createdAt:(NSDate *)myCreatedAt
    withMeetingUUID:(UUID *)myMeetingUUID 
           withText:(NSString *)myText
     assignedToUUID:(UUID *)myAssignedToUUID
     assignedByUUID:(UUID *)myAssignedByUUID
         assignedAt:(NSDate *)myAssignedAt;

- (void) deassignByActor:(Actor *)newAssignedBy atTime:(NSDate *)deassignTime;
- (void) assignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime;

- (UIView *)getView;

@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) User *assignedTo;
@property(nonatomic, retain) Actor *assignedBy;
@property(nonatomic, retain) NSDate *assignedAt;

@end
