//
//  Location.m
//  TinCan
//
//  Created by Drew Harry on 7/15/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Location.h"
#import "StateManager.h"
#import "Meeting.h"
#import "tincan.h"
#import "LocationView.h"

@implementation Location

@synthesize meeting;
@synthesize users;
@synthesize color;

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withMeeting:(UUID *)myMeetingUUID withUsers:(NSArray *)myUsers withColor:(UIColor *)theColor {
    self = [super initWithUUID:myUuid withName:myName withStatus:nil atDate:nil];
    
    meetingUUID = [myMeetingUUID retain];

    
    // Make the mutable version of the set, then populate it
    // by unioning in the initialization set. this allows people
    // calling self constructor to use NSMutableSet or NSSet
    // and we don't care because we'll construct a fresh one for
    // our use.
    self.users = [NSMutableSet set];
    [self.users addObjectsFromArray:myUsers];
    
    self.color = theColor;
    
    return self;
}

- (void) userJoined:(User *)theUser {
    [self.users addObject:theUser];
    theUser.location = self;
    
    if(meeting != nil) {
        [meeting userJoined:theUser theLocation:self];
    }
}

- (void) userLeft:(User *)theUser {
    [self.users removeObject:theUser];
    theUser.location = nil;

    if(meeting != nil) {
        [meeting userLeft:theUser theLocation:self];
    }
}

- (void) joinedMeeting:(Meeting *)theMeeting {
    self.meeting = theMeeting;
}

- (void) leftMeeting:(Meeting *)theMeeting {
    self.meeting = nil;
}   

- (BOOL) isInMeeting {
    return self.meeting != nil;
}

- (void) unswizzle {
       
    NSLog(@"unswizzling location");
    
    NSMutableSet *newUsersList = [[NSMutableSet set] retain];
    for(NSString *userUUID in self.users) {
        User *user = (User *)[[StateManager sharedInstance] getObjWithUUID:userUUID withType:User.class];
        
        
        [newUsersList addObject:user];
        user.location = self;
    }
    self.users = newUsersList;
    [newUsersList release];
    
    // This test checks to see if it's a UUID object. If it's not, 
    // it's probably an NSNull object, which means we don't have a UUID set.
    if([meetingUUID isKindOfClass:[UUID class]]) {
        if(self.meeting!=nil) {
            [self.meeting release];
        }
        self.meeting = (Meeting *)[[StateManager sharedInstance] getObjWithUUID:meetingUUID withType:Meeting.class];
        [self.meeting locationJoined:self];
    }
    [meetingUUID release];
}

- (NSString *)description {
    
    if([self isInMeeting]) 
        return [NSString stringWithFormat:@"[loc.%@ %@ meet:%@ users:%d color:%@]", [self.uuid substringToIndex:6],
            self.name, self.meeting, [self.users count], self.color];
    else 
        return [NSString stringWithFormat:@"[loc.%@ %@ meet:null users:%d color: %@]", [self.uuid substringToIndex:6],
                self.name, [self.users count], self.color];

}

- (UIView *)getView {
    
    if(view==nil) {
        // construct a new TaskView
        view = [[LocationView alloc] initWithLocation:self];
    }
    
    // return the current view
    return view;
}

@end
