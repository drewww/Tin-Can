//
//  Actor.h
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynchronizedObject.h"

@interface Actor : SynchronizedObject {
    NSString *name;
}

- (id) initWithUUID:(NSString *)myUuid withName:(NSString *)myName;

@property(nonatomic, retain) NSString *name;

@end
