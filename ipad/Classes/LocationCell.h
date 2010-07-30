//
//  LocationCell.h
// 
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationCellView.h"
#import "Location.h"
@interface LocationCell : UITableViewCell {
    LocationCellView *locCellView;
    Location *loc;
}

- (void) setLoc:(Location *)newLoc;

//@property (nonatomic, retain) Location *loc;

@end
