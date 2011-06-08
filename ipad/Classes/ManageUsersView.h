//
//  ManageUsersView.h
//  TinCan
//
//  Created by Drew Harry on 6/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ExtendableDrawerView.h"
#import "ManageUsersRenderView.h"

@interface ManageUsersView : ExtendableDrawerView {
    ManageUsersRenderView *renderView;
}

- (id) initWithLocation:(Location *)theLocation;

@end
