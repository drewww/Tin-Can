//
//  BaseMeetingObject.m
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "BaseMeetingObject.h"


@synthesize creator;
@synthesize createdAt;
@synthesize meeting;

@implementation BaseMeetingObject

- (id) initWithUUID:(UUID *)myUUID withCreatorUUID:(UUID *)myCreatorUUID createdAt:(NSDate *)myCreatedAt 
    withMeetingUUID:(UUID *)myMeetingUUID {
    
    self = [super initWithUUID:myUUID];
    
    creatorUUID = myCreatorUUID;
    meetingUUID = myMeetingUUID;
}

- (void) unswizzle {
    self.creator = (User *)[[StateManager sharedInstance] getObjWithUUID:creatorUUID withType:[User class]];
    self.meeting = (Meeting *) [[StateManager sharedInstance] getObjWithUUID:meetingUUID withType:[Meeting class]];
}

@end
