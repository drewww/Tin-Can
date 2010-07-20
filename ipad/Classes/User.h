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

@class Location;

@interface User : Actor {
    Location *location;
    
    UUID *locationUUID;
}

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withLocationUUID:(UUID *)myLocation;
- (BOOL) isInLocation;
- (BOOL) isinMeeting;

@property(nonatomic, retain) Location *location;

@end
