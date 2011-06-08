//
//  ManageUsersView.m
//  TinCan
//
//  Created by Drew Harry on 6/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersView.h"
#import "UIView+Rounded.h"

@implementation ManageUsersView

- (id) initWithLocation:(Location *)theLocation {

    UIView *baseUIView = [[[UIView alloc] initWithFrame:CGRectMake(-[self getBaseWidth], +15, [self getBaseWidth]*2, 600)] autorelease];
    
    self = [super initWithFrame:CGRectMake(0, 0, [self getBaseWidth], [self getBaseHeight]) withDrawerView:baseUIView];
    
    self.controller = nil;
    
    baseUIView.backgroundColor = [UIColor redColor];
    
    self.bounds = CGRectMake(-[self getBaseWidth]/2, -([self getBaseHeight] + 50)/2, [self getBaseWidth], [self getBaseHeight] + 50);
    
    return self;
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"Got a touch on the ManageUsersView!");
    
    [self setDrawerExtended:!drawerExtended];
    
    [controller userTaskDrawerExtended:self];
}


- (void)drawRect:(CGRect)rect {
    NSLog(@"In drawRect for ManageUsersView");
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if(ctx==nil) {
        NSLog(@"Failed to get graphics context.");
        return;
    }
    

//    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
//    NSLog(@"bounds: %@", NSStringFromCGRect(self.bounds));
//    CGContextStrokeRect(ctx, self.bounds);
//    
//    CGContextStrokeRect(ctx, CGRectMake(-2, -2, 4, 4));
    
    CGFloat topEdge;
    
    topEdge = -[self getBaseHeight]/2 +10;    
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.3 alpha:1.0].CGColor);
    
    [self fillRoundedRect:CGRectMake(-[self getBaseWidth]/2, topEdge, [self getBaseWidth], [self getBaseHeight]) withRadius:10 withRoundedBottom:true];        
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    UIFont *f = [UIFont boldSystemFontOfSize:16];
    NSString *managerUsersTitle = @"Add Participant";
    
    CGSize stringSize = [[managerUsersTitle uppercaseString] sizeWithFont:f];
    
    CGContextSaveGState(ctx);
    if([self.side isEqualToNumber:[NSNumber numberWithInt:0]]) {
        CGContextRotateCTM(ctx, M_PI);
        [[managerUsersTitle uppercaseString] drawAtPoint:CGPointMake(-stringSize.width/2, 2) withFont:f];
    } else {
        [[managerUsersTitle uppercaseString] drawAtPoint:CGPointMake(-stringSize.width/2, -stringSize.height-2) withFont:f];
    }
    
}

- (void) wasLaidOut {
    
    NSLog(@"in WAS LAID OUT for MANAGE USERS VIEW. side: %d", [self.side intValue]);
    
    [super wasLaidOut];
}

@end
