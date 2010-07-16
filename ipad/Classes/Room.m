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

- (id) initWithUUID:(NSString *)myUuid withName:(NSString *)myName {
    self = [super initWithUUID:myUuid];
 
    self.name = myName;
            
    return self;
}

- (void) setMeeting:(Meeting *)myMeeting {
    
    self.currentMeeting = myMeeting;
}
            
- (void) unswizzle {
    if(self.currentMeeting != nil) {
        self.currentMeeting = [[StateManager sharedInstance] getObjWithUUID:self.currentMeeting withType:Meeting.class];
    }
}


@end
