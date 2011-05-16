//
//  LocationCellView.h
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "LocationViewController.h"

@interface LocationCellView : UIView {
    Location *loc;
    
    LocationViewController *controller;
}

@end