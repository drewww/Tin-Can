//
//  TinCanViewController.h
//  TinCan
//
//  Created by Drew Harry on 7/12/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TinCanViewController : UIViewController {
    UIViewController *currentViewController;
}
-(void) switchToViewController:(UIViewController *)c;
@end
