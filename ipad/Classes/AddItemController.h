//
//  AddItemController.h
//  TinCan
//
//  Created by Drew Harry on 12/6/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddItemDelegate 
- (void) itemSubmittedWithText:(NSString *)text;
@end 

@interface AddItemController : UIViewController {

    
    UITextField *textField;
    UIButton *submitButton;
    NSString *placeholder;
    NSString *buttonLabel;
    
    id <AddItemDelegate> delegate;
}

- (id) initWithPlaceholder:(NSString *)placeholderString withButtonText:(NSString *)buttonLabelString;
- (void) submitButtonPressed:(id) sender;

@property (nonatomic, assign) id <AddItemDelegate> delegate;

@end
