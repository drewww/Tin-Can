//
//  Actor.m
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Actor.h"


@implementation Actor

@synthesize name;
@synthesize statusMessage;
@synthesize statusDate;

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withStatus:(NSString *)theStatus atDate:(NSDate *)theDate {
    
    self = [super initWithUUID:myUuid];
    
    self.name = myName;
    
    if([theStatus isKindOfClass:[NSNull class]]) {
        self.statusMessage = nil;
        self.statusDate = nil;
    } else {
        self.statusMessage = theStatus;
        self.statusDate = theDate;
    }
    
    return self;
}

- (void) setStatusMessage:(NSString *)theStatus atDate:(NSDate *)theDate {
    
    self.statusMessage = theStatus;
    self.statusDate = theDate;
}

@end
