//
//  ManageUsersView.m
//  TinCan
//
//  Created by Drew Harry on 6/9/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersView.h"


@implementation ManageUsersView

@synthesize extended;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 344, 668)];
    if (self) {
        
        NSLog(@"MAKING A MANAGE USERS VIEW@@@@@@@@@@@");
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1.0;
    
        tableController = [[ManageUsersTableViewController alloc] init];
        [self addSubview:tableController.view];
        tableController.view.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2 + 35);
    
        UIView *transparentBackground = [[UIView alloc] initWithFrame:self.bounds];
        transparentBackground.backgroundColor = [UIColor blackColor];
        transparentBackground.alpha = 0.8;
        
        [self addSubview:transparentBackground];
        [self sendSubviewToBack:transparentBackground];
        
        self.extended = false;
    }
    
    return self;
}

- (void) setExtended:(_Bool)toExtended {
    extended = toExtended;
    
    [tableController updateUsers];
}

- (void) drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.8 alpha:1.0].CGColor);
    CGContextSetLineWidth(ctx, 5);
    CGContextStrokeRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    [@"Tap names to mark them as in the room with you. Tap anywhere else to dismiss." drawInRect:CGRectMake(10, 10, self.bounds.size.width - 20, 80) withFont:[UIFont boldSystemFontOfSize:20]];
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
