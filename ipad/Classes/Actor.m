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

- (id) initWithUUID:(NSString *)myUuid withName:(NSString *)myName {
    self = [super initWithUUID:myUuid];
    
    self.name = myName;
    
    return self;
}

@end
