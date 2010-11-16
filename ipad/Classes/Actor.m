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
@synthesize status;
@synthesize statusDate;

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withStatus:(NSString *)theStatus atDate:(NSDate *)theDate {
    
    self = [super initWithUUID:myUuid];
    
    self.name = myName;
    
    self.status = theStatus;
    self.statusDate = theDate;
    
    return self;
}

- (void) setStatus:(NSString *)theStatus atDate:(NSDate *)theDate {
    
    self.status = theStatus;
    self.statusDate = theDate;
}

@end
