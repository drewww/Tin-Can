//
//  HeaderView.h
//  Login
//
//  Created by Paula Jacobs on 7/2/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HeaderView : UIView {
	NSString *label;

}
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title;
@end
