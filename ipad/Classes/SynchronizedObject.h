//
//  SynchronizedObject.h
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tincan.h"

@interface SynchronizedObject : NSObject {
    UUID *uuid;
}

- (id) initWithUUID:(UUID *) uuid;

@property(nonatomic, retain) UUID *uuid;

@end
