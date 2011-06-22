//
//  User.h
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Location.h"
#import "tincan.h"

typedef enum {
    kEMPTY_STATUS,
    kTHUMBS_UP_STATUS,
    kRAISE_HAND_STATUS,
    kMOVE_ON_STATUS,
} StatusType;

@class Location;

@interface User : Actor {
    Location *location;
    
    UUID *locationUUID;
    
    NSMutableSet *tasks;
    
    UIView *view;
    
    StatusType statusType;
}

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withLocationUUID:(UUID *)myLocationUUID withStatus:(NSString *)theStatus atDate:(NSDate *)theDate;
- (BOOL) isInLocation;
- (BOOL) isinMeeting;

- (void) assignTask:(id)task;
- (void) removeTask:(id)task;

- (UIView *)getView;

@property(nonatomic, retain) Location *location;
@property(nonatomic, retain) NSMutableSet *tasks;
@property(nonatomic) StatusType statusType;

@end
