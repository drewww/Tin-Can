//
//  UserContainer.m
//  TinCan
//
//  Created by Drew Harry on 8/12/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserContainer.h"


@implementation UserContainer


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


// This is pretty much the UserContainer's only job - lay user objects out inside it.
- (void)layoutSubviews{
    int numViews = [[self subviews] count];
    
    int i = 0;
    int arrayCounter=0;
    int sideLimit= ceil(numViews/4.0);
    int topLimit=trunc(numViews/4.0);

    //assigns number of participants to a side
    NSMutableArray *sides=[[NSMutableArray arrayWithObjects:[NSNumber numberWithInt: 0],[NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:0],[NSNumber numberWithInt:0],nil]retain];
    
    while (i<numViews) {
        if (arrayCounter==1 && ([[sides objectAtIndex:arrayCounter] intValue]>=topLimit)) {
            arrayCounter++;
        }
        else if ((arrayCounter==0 || arrayCounter==2)&&([[sides objectAtIndex:arrayCounter] intValue] >=sideLimit)){
            arrayCounter++;
        }
        else if(arrayCounter==3){
            if ([[sides objectAtIndex:arrayCounter] intValue]>topLimit) {
                break;
            }
            else {
                [sides replaceObjectAtIndex: arrayCounter withObject:[NSNumber numberWithInt:[[sides objectAtIndex:arrayCounter] intValue] +1.0]];
                arrayCounter=0;	
                i++;
            }
        }
        else {
            [sides replaceObjectAtIndex: arrayCounter withObject:[NSNumber numberWithInt:[[sides objectAtIndex:arrayCounter] intValue] +1.0]];
            i++;
            arrayCounter++;
        }	
        
    }
    //Forms points from side assignments
    NSMutableArray *points=[[NSMutableArray alloc] initWithCapacity:numViews];
    NSMutableArray *rotations=[[NSMutableArray alloc] initWithCapacity:numViews];
    for (i=0; i<4; i++) {
        int c =1;
        while (c<=[[sides objectAtIndex:i] intValue]) {
            if (i==0|| i==2) {
                float divisions=1024.0/[[sides objectAtIndex:i] intValue];
                float yVal= (divisions*c) -(divisions/2.0);
                if (i==0) {
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, yVal)]];
                    [rotations addObject:[NSNumber numberWithFloat:M_PI/2]];
                    
                }	
                else{
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(768, yVal)]];
                    
                    [rotations addObject:[NSNumber numberWithFloat:-M_PI/2]]; 
                }
            }
            else if (i==1 || i==3) {
                float divisions=768/[[sides objectAtIndex:i] intValue];
                float xVal= (divisions*(c)) -(divisions/2.0);
                if (i==1) {
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(xVal, 0)]]; 
                    [rotations addObject:[NSNumber numberWithFloat:M_PI]];
                }	
                else{
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(xVal, 1024)]];
                    [rotations addObject:[NSNumber numberWithFloat:0.0]];
                }
            }
            c++;
        }
    }

    // Now that we've done all the layout math, put everything in its place.
    int viewIndex = 0;
    for(UIView *view in [self subviews]) {
        view.center = [[points objectAtIndex:viewIndex] CGPointValue];
        [view setTransform:CGAffineTransformMakeRotation([[rotations objectAtIndex:viewIndex] floatValue])];
        
        viewIndex++;
    }
}	

- (void)dealloc {
    [super dealloc];
}


@end
