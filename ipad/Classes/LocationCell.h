//
//  LocationCell.h
// 
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationCellView.h"

@interface LocationCell : UITableViewCell {
    LocationCellView *locCellView;
    NSString *loc;
}

- (void) setLoc:(NSString *)newLoc;

@property (nonatomic, retain) NSString *loc;

@end
