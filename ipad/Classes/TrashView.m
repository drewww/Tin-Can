//
//  TrashView.m
//  TinCan
//
//  Created by Drew Harry on 2/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "TrashView.h"
#import "UIView+Rounded.h"
#import "UIColor+Util.h"
#import "UserView.h"


#define COLOR [UIColor colorWithWhite:0.3 alpha:1.0]

@implementation TrashView


- (id)init {
    
    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT + TAB_HEIGHT)];
    if (self) {

        self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT + TAB_HEIGHT)/2, BASE_WIDTH, BASE_HEIGHT + TAB_HEIGHT);
        self.center = CGPointMake(0, 0);

        hover = false;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}


// this code is largely lifted from UserRenderView, with much simplification and lots
// of changes.

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if(hover)
        CGContextSetFillColorWithColor(ctx, [COLOR colorDarkenedByPercent:0.3].CGColor);
	else
		CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
        
    CGFloat topEdge;
    
    topEdge = -BASE_HEIGHT/2 +10;
    
    [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        
    
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    
    UIFont *f = [UIFont boldSystemFontOfSize:16];
    
    NSString *name = @"TRASH";
    CGSize nameSize = [name sizeWithFont:f];
    
    [name drawAtPoint:CGPointMake(-nameSize.width/2, -nameSize.height-NAME_BOTTOM_MARGIN) withFont:f];
}

- (void) setHoverState:(bool)state {
    hover = state;
    [self setNeedsDisplay];
}

- (void) wasLaidOut {
    
}

- (void)dealloc {
    [super dealloc];
}


@end
