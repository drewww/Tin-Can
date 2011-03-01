//
//  UIView+Rounded.m
//  TinCan
//
//  Created by Drew Harry on 2/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "UIView+Rounded.h"


@implementation UIView (Rounded)

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


@end
