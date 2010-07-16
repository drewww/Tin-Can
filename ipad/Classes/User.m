//
//  User.m
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "User.h"
#import "Location.h"


@implementation User

@synthesize location;

- (id) initWithUUID:(NSString *)myUuid withName:(NSString *)myName withLocation:(Location *)myLocation {
    self = [super initWithUUID:myUuid withName:myName];
    
    self.location = myLocation;
    
    return self;
}

- (BOOL) isInLocation {
    return self.location!=nil;
}

- (BOOL) isinMeeting {
    if ([self isinLocation]) {
        return [self.location isInMeeting];
    } else {
        return nil;
    }
}


@end
