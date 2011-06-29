//
//  UserBadgeView.m
//  TinCan
//
//  Created by Drew Harry on 6/23/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "UserBadgeView.h"
#import "UserView.h"

#define BADGE_DIAMETER 30

@implementation UserBadgeView

- (id)initWithUser:(User *)theUser
{
    self = [super initWithFrame:CGRectMake(-BADGE_DIAMETER/2, -BADGE_DIAMETER, BADGE_DIAMETER, BADGE_DIAMETER)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        user = [theUser retain];
        
//        icon = [[UIImage imageNamed:@"note_add.png"] retain];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
        if(user.statusType == kTHUMBS_UP_STATUS) {
            [icon release];
            icon = [[UIImage imageNamed:@"thumb_up.png"] retain];
            NSLog(@"setting image to THUMBS UP!");
        } else if (user.statusType == kEMPTY_STATUS) {
            icon = nil;
        }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    // This is a sort of reddish color, which felt badge-like originally.
    // Switched to green to fit better with thumbs up.
    
//    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:191.0/255.0 green:101.0/255.0 blue:114.0/255.0 alpha:1.0].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:112/255.0 green:185.0/255.0 blue:52/255.0 alpha:1.0].CGColor);
        
    CGContextFillEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));
    CGContextStrokeEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));
    
    // We want to draw this upside down if the side we're on is the top one.
    // This turns out to be annoying. Not going to do it, since there's no thumbs down, anyway.
//    if([((UserView *)self.superview.superview).side isEqualToNumber:[NSNumber numberWithInt:0]]) {
//        CGContextRotateCTM(ctx, M_PI);
//    }
    
    if(icon!=nil) {
        [icon drawInRect:CGRectInset(self.bounds, 8, 8)];
    }
}


- (void)dealloc
{
    [user retain];
    [super dealloc];
}

@end
