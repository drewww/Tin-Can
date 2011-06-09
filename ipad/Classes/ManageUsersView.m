//
//  ManageUsersView.m
//  TinCan
//
//  Created by Drew Harry on 6/9/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersView.h"


@implementation ManageUsersView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 984, 728)];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.alpha = 0.8;
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    
    [@"HELLO WORLD" drawInRect:self.bounds withFont:[UIFont boldSystemFontOfSize:72]];
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
