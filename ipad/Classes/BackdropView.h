//
//  BackdropView.h
//  TinCan
//
//  Created by Drew Harry on 3/21/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackdropViewDelegate
- (void) backdropTouchedFrom:(id)sender;
@end


@interface BackdropView : UIView {
    id <BackdropViewDelegate> delegate;
}

@property (nonatomic, assign) id <BackdropViewDelegate> delegate;

@end
