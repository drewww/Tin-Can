//
//  LocationCell.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LocationCell.h"


@implementation LocationCell

@synthesize loc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
       
        CGRect tzvFrame = CGRectMake(0.0, 0.0, 320, self.contentView.bounds.size.height);

        locCellView = [[LocationCellView alloc] initWithFrame:tzvFrame];
        locCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:locCellView];
    }
    return self;
}


//Setter for Location
- (void)setLoc:(NSString *)newLoc {
    
    [locCellView setLoc:newLoc];
}

- (void)dealloc {
    [super dealloc];
}


@end
