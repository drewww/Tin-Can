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
#import "Task.h"

@implementation User

@synthesize location;
@synthesize tasks;

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withLocationUUID:(UUID *)myLocationUUID {
    self = [super initWithUUID:myUuid withName:myName];
    
    // Why is this included at all? Can we get rid of it?
    locationUUID = myLocationUUID;
    
    self.tasks = [NSMutableSet set];
    
    return self;
}

- (void) assignTask:(id)task {
    if([task isKindOfClass:[Task class]]) {
        [self.tasks addObject:task];
    }
}

- (void) removeTask:(id)task {
    if([task isKindOfClass:[Task class]]) {
        [self.tasks removeObject:task];
    }
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

- (NSString *)description {
    if([self isInLocation]) 
        return [NSString stringWithFormat:@"[user.%@ %@ loc:%@]", [self.uuid substringToIndex:6],
                self.name, self.location];
    else
        return [NSString stringWithFormat:@"[user.%@ %@ loc:null]", [self.uuid substringToIndex:6],
                self.name, self.location];
}


- (void) unswizzle {
    
    // Don't need to do this. When the location unswizzles, it will set its users' location
    // pointer to itself. 
//    if(locationUUID != nil) {
//        self.location = [[StateManager sharedInstance] getObjWithUUID:locationUUID withType:Location.class];
//    }
    
}

@end
