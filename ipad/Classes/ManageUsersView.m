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
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1.0;
    
        tableController = [[ManageUsersTableViewController alloc] init];
        [self addSubview:tableController.view];
        tableController.view.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
        UIView *transparentBackground = [[UIView alloc] initWithFrame:self.bounds];
        transparentBackground.backgroundColor = [UIColor blackColor];
        transparentBackground.alpha = 0.8;
        
        [self addSubview:transparentBackground];
        [self sendSubviewToBack:transparentBackground];
    }
    
    return self;
}

- (void) drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
