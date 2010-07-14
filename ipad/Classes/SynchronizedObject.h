//
//  SynchronizedObject.h
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SynchronizedObject : NSObject {
    NSString *uuid;
}

- (id) initWithUUID:NSString *uuid;

@property(nonatomic, retain) NSString *uuid;

@end
