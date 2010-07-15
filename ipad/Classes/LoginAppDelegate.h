//
//  LoginAppDelegate.h
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LoginMasterViewController;


@interface LoginAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LoginMasterViewController *viewController;

	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LoginMasterViewController *viewController;


@end

