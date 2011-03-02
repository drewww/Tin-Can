//
//  AddItemController.h
//  TinCan
//
//  Created by Drew Harry on 12/6/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddItemDelegate 
- (void) itemSubmittedWithText:(NSString *)text fromController:(UIViewController *)controller isAltSubmit:(bool)isAlt;
@end 

@interface AddItemController : UIViewController {

    
    UITextField *textField;
    UIButton *submitButton;
    UIButton *altSubmitButton;
    
    NSString *placeholder;
    NSString *buttonLabel;
    NSString *altButtonLabel;
    
    id <AddItemDelegate> delegate;
}

- (id) initWithPlaceholder:(NSString *)placeholderString withButtonText:(NSString *)buttonLabelString withAltButtonText:(NSString *)altButtonLabelString;
- (void) altSubmitButtonPressed:(id) sender;

@property (nonatomic, assign) id <AddItemDelegate> delegate;

@end
