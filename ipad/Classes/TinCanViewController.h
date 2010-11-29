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
    
    
    NSString *server;
}

-(void) switchToViewController:(UIViewController *)c;
-(void) animateNewViewDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context;

- (void) setServer: (NSString *)theServer;

@end
