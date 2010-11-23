//
//  ServerSelectViewController.h
//  TinCan
//
//  Created by Drew Harry on 11/19/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TinCanViewController.h"

@interface ServerSelectViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    TinCanViewController *controller;
    
    
    UIPickerView *picker;
    UIButton *selectServerButton;
    
    NSArray *servers;
    
}


- (id) initWithController:(TinCanViewController *)theController;

@end
