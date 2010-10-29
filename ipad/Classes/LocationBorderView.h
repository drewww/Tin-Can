//
//  LocationBorderView.h
//  TinCan
//
//  Created by Drew Harry on 10/20/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserView.h"

@interface LocationBorderView : UIView {

}

- (int) hasSharedEdgeBetweenView:(UserView *)view1 andView:(UserView *)view2;


@end
