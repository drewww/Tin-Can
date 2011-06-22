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
    
    NSString *statusMessage;
    NSDate *statusDate;
}

- (id) initWithUUID:(UUID *)myUuid withName:(NSString *)myName withStatus:(NSString *)theStatus atDate:(NSDate *)theDate;

- (void) setStatusMessage:(NSString *)theStatus atDate:(NSDate *)theDate;

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *statusMessage;
@property(nonatomic, retain) NSDate *statusDate;

@end
