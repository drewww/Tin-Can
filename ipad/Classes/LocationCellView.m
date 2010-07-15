//
//  LocationCellView.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LocationCellView.h"


@implementation LocationCellView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//Setter for Location
- (void) setLoc:(NSString *)newLoc {
    loc = newLoc;
}

// Fills the cell with information on Location
- (void)drawRect:(CGRect)rect {
    NSString *string =[@" " stringByAppendingString:loc];
    [[UIColor blackColor] set];
    [string drawInRect:self.bounds withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
}

- (void)dealloc {
    [super dealloc];
}


@end
