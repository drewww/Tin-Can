//
//  ServerSelectViewController.h
//  TinCan
//
//  Created by Drew Harry on 11/19/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TinCanViewController.h"

@interface ServerSelectViewController : UIViewController <UITextFieldDelegate> {
    TinCanViewController *controller;
        
    
    NSArray *servers;
    
}


- (id) initWithController:(TinCanViewController *)theController;

@end
