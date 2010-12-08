//
//  AddUserButton.h
//  TinCan
//
//  Created by Drew Harry on 12/8/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddUserController.h"

@interface AddUserButton : UIView <AddUserDelegate> {
    UIPopoverController *addUserPopover;
    
    bool buttonPressed;
}

@end
