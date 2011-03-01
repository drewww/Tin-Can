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
    
    UIColor *color;
}


- (id) initWithUUID:(UUID *)myUUID withCreatorUUID:(UUID *)myCreatorUUID
          createdAt:(NSDate *)myCreatedAt
    withMeetingUUID:(UUID *)myMeetingUUID 
           withText:(NSString *)myText
     assignedToUUID:(UUID *)myAssignedToUUID
     assignedByUUID:(UUID *)myAssignedByUUID
         assignedAt:(NSDate *)myAssignedAt
          withColor:(UIColor *)myColor;

- (void) startDeassignByActor:(Actor *)byActor atTime:(NSDate *)deassignTime withTaskContainer:(UIView *)taskContainer;
- (void) deassignByActor:(Actor *)byActor atTime:(NSDate *)deassignTime;
    
- (void) startAssignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime;
- (void) assignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime;

- (void) deleteTask;

- (UIView *)getView;

- (bool) isAssigned;

@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) User *assignedTo;
@property(nonatomic, retain) Actor *assignedBy;
@property(nonatomic, retain) NSDate *assignedAt;
@property(nonatomic, retain) UIColor *color;

@end
