//
//  TrashView.h
//  TinCan
//
//  Created by Drew Harry on 2/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDropTarget.h"

@interface TrashView : UIView <TaskDropTarget> {
    bool isHovered;
}

@end
