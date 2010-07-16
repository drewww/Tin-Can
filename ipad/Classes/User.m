//
//  User.m
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "User.h"
#import "Location.h"
#import "tincan.h"


@implementation User

@synthesize location;

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withLocation:(Location *)myLocation {
    self = [super initWithUUID:myUuid withName:myName];
    
    self.location = myLocation;
    
    return self;
}

- (BOOL) isInLocation {
    return self.location!=nil;
}

- (BOOL) isinMeeting {
    if ([self isInLocation]) {
        return [self.location isInMeeting];
    } else {
        return FALSE;
    }
}


@end
