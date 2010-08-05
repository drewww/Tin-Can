//
//  UserView.m
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserView.h"
#import "UIColor+Util.h"

@implementation UserView

@synthesize user;
@synthesize hover;

#define BASE_HEIGHT 70
#define BASE_WIDTH 150

// Messing with this also works for debugging. Set it huge to have max height visibility.
#define HEIGHT_MARGIN 200

#define TAB_WIDTH 15
#define TAB_HEIGHT 8
#define TAB_MARGIN 5

#define STATUS_HEIGHT 30

#define NAME_BOTTOM_MARGIN 5

- (id) initWithUser:(User *)theUser {
    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT + HEIGHT_MARGIN)];
    
    self.user = theUser;
    hover = FALSE;
    
    self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT + HEIGHT_MARGIN)/2, BASE_WIDTH, BASE_HEIGHT + HEIGHT_MARGIN);
//    self.center = CGPointMake(500, 500);
    
    color = [UIColor blueColor];
    
    showStatus = FALSE;
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if(ctx==nil) {
        NSLog(@"Failed to get graphics context.");
        return;
    }

    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGContextAddEllipseInRect(ctx, CGRectMake(-10, -10, 20, 20));
    CGContextFillPath(ctx);
    
	if(hover)
        CGContextSetFillColorWithColor(ctx, [color colorDarkenedByPercent:0.3].CGColor);
	else
		CGContextSetFillColorWithColor(ctx, color.CGColor);
    
    
    CGFloat topEdge;
    
    if(showStatus) {
        topEdge = -BASE_HEIGHT/2 - STATUS_HEIGHT;
        
    } else {
        topEdge = -BASE_HEIGHT/2;
    }

    [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        
    
    
    
    
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);

    UIFont *f = [UIFont boldSystemFontOfSize:16];
    CGSize nameSize = [[self.user.name uppercaseString] sizeWithFont:f];
    
    [[self.user.name uppercaseString] drawAtPoint:CGPointMake(-nameSize.width/2, -nameSize.height-NAME_BOTTOM_MARGIN) withFont:f];
    
    
    
    // Handle status drawing.
    if(showStatus) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithHue:0.65 saturation:0.5 brightness:1.0 alpha:1.0].CGColor);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        
        [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, STATUS_HEIGHT) withRadius:10 withRoundedBottom:false];        
        
        NSString *statusString = @"POSTED TASK";
        
        UIFont *statusFont = [UIFont boldSystemFontOfSize:12];
        CGSize statusSize = [statusString sizeWithFont:statusFont];
        
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        [statusString drawAtPoint:CGPointMake(-statusSize.width/2, topEdge + STATUS_HEIGHT/2 - statusSize.height/2) withFont:statusFont];
        
    }
    
    
    
    // Draw the tabs to show that this person has tasks assigned.
    // Hardcoding the number of tasks for now.
    CGContextSetFillColorWithColor(ctx, [color colorByChangingAlphaTo:0.6].CGColor);
    CGFloat xPos = 15;
    for (int i=0; i<3; i++) {
        CGContextFillRect(ctx, CGRectMake(xPos-BASE_WIDTH/2, topEdge-TAB_HEIGHT, TAB_WIDTH, TAB_HEIGHT));
        
        xPos += TAB_MARGIN + TAB_WIDTH;
    }
}

- (void) fillRoundedRect:(CGRect)boundingRect withRadius:(CGFloat)radius withRoundedBottom:(bool)roundedBottom{

    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // This code lifted from Apple's quartz example code:
    // http://developer.apple.com/iphone/library/samplecode/QuartzDemo/Listings/Quartz_QuartzCurves_m.html
    
    // If you were making this as a routine, you would probably accept a rectangle
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
    CGRect rrect = boundingRect;
    
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.
    
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.
    
    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    // Next, we will go around the rectangle in the order given by the figure below.
    //       minx    midx    maxx
    // miny    2       3       4
    // midy   1 9              5
    // maxy    8       7       6
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
    // form a closed path, so we still need to close the path to connect the ends correctly.
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
    // You could use a similar technique to create any shape with rounded corners.
    
    // Start at 1
    CGContextMoveToPoint(ctx, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radius);
    
    if(roundedBottom) {
        // Add an arc through 6 to 7
        CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radius);
        // Add an arc through 8 to 9
        CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radius);
    } else {
        // Just go directly to the next two corners, with no arc.
        CGContextAddLineToPoint(ctx, maxx, maxy);
        CGContextAddLineToPoint(ctx, minx, maxy);
        CGContextAddLineToPoint(ctx, minx, midy);
    }
    
    // Close the path
    CGContextClosePath(ctx);
    // Fill & stroke the path
    CGContextDrawPath(ctx, kCGPathFillStroke);   
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    showStatus = !showStatus;
    [self setNeedsDisplay];
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	// We want to do our hit test a little differently - just return true
	// if it's inside the circle part of the participant rendering.
	CGFloat distance = sqrt(pow(point.x, 2) + pow(point.y, 2));
    
	if (distance <= 130.0f) {
		return self;	
	}
	else {
		return nil;
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
