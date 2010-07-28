//
//  BaseMeetingObject.m
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "BaseMeetingObject.h"
#import "StateManager.h"


@implementation BaseMeetingObject
@synthesize creator;
@synthesize createdAt;
@synthesize meeting;


- (id) initWithUUID:(UUID *)myUUID withCreatorUUID:(UUID *)myCreatorUUID withMeetingUUID:(UUID *)myMeetingUUID
          createdAt:(NSDate *)myCreatedAt {
    
    self = [super initWithUUID:myUUID];
    
    creatorUUID = myCreatorUUID;
    meetingUUID = myMeetingUUID;
    
    return self;
}

- (void) unswizzle {
    self.creator = (User *)[[StateManager sharedInstance] getObjWithUUID:creatorUUID withType:[User class]];
    self.meeting = (Meeting *) [[StateManager sharedInstance] getObjWithUUID:meetingUUID withType:[Meeting class]];
}

@end
