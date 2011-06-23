//
//  UserBadgeView.m
//  TinCan
//
//  Created by Drew Harry on 6/23/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "UserBadgeView.h"

#define BADGE_DIAMETER 30

@implementation UserBadgeView

- (id)initWithUser:(User *)theUser
{
    self = [super initWithFrame:CGRectMake(-BADGE_DIAMETER/2, -BADGE_DIAMETER, BADGE_DIAMETER, BADGE_DIAMETER)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        user = [theUser retain];
        
        icon = [[[UIImageView alloc] initWithFrame:CGRectMake(-BADGE_DIAMETER/2 + 5, -BADGE_DIAMETER/2+5, BADGE_DIAMETER-10, BADGE_DIAMETER-10)] retain];
        [self addSubview:icon];
        icon.hidden = true;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Queue off the setHidden so whenever this is shown
    // we've updated the image to be proper.
        // Now we're going to draw the icon (later)
        if(user.statusType == kTHUMBS_UP_STATUS) {
            [icon setImage:[UIImage imageNamed:@"thumbs_up.png"]];
            icon.center = CGPointMake(0, 0);
            [icon setNeedsDisplay];
            [self bringSubviewToFront:icon];
            icon.hidden = false;
            NSLog(@"setting image to THUMBS UP!");
        } else if (user.statusType == kEMPTY_STATUS) {
            icon.hidden = true;
        }

    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:191.0/255.0 green:101.0/255.0 blue:114.0/255.0 alpha:1.0].CGColor);
        
    CGContextFillEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));
    CGContextStrokeEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));
    
}


- (void)dealloc
{
    [user retain];
    [super dealloc];
}

@end
