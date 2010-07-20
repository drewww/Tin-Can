//
//  Room.m
//  TinCan
//
//  Created by Drew Harry on 7/15/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Room.h"
#import "StateManager.h"

@implementation Room

@synthesize name;
@synthesize currentMeeting;

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName {
    self = [super initWithUUID:myUuid];
 
    self.name = myName;
            
    return self;
}

- (void) setMeeting:(Meeting *)myMeeting {
    
    self.currentMeeting = myMeeting;
}
            
- (void) unswizzle {
    
    //NSLog(@"Rooms don't need to be unswizzled.");
    // As currently architected, there's no need for this. You can't init rooms with a meeting
    // at the moment. When you can, this will need to get turned back on. But to turn it on,
    // we need to add a currentMeetingUUID indirection and I don't feel like doing it right now.
//    if(self.currentMeeting != nil) {
//        self.currentMeeting =  (Meeting *)[[StateManager sharedInstance] getObjWithUUID:self.currentMeeting withType:Meeting.class];
//    }
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[room.%@ %@ meet:%@]", [self.uuid substringToIndex:6],
            self.name, self.currentMeeting];
}

@end
