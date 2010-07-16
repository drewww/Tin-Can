//
//  SynchronizedObject.m
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "SynchronizedObject.h"
#import "StateManager.h"
#import "tincan.h"


@implementation SynchronizedObject

@synthesize uuid;

- (id) initWithUUID:(UUID *)myUuid {
    self = [super init];
    
    self.uuid = myUuid;
    
    // Register this object with the main object store.
    [[StateManager sharedInstance] putObj:self withUUID:self.uuid];
    
    return self;
}

@end
