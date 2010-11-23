//
//  ServerSelectViewController.m
//  TinCan
//
//  Created by Drew Harry on 11/19/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "ServerSelectViewController.h"


@implementation ServerSelectViewController


- (id) initWithController:(TinCanViewController *)theController {
    
    if((self = [super init])) {
        
        controller = theController;
        
        servers = [[NSArray arrayWithObjects:@"localhost", @"18.85.35.212", nil] retain];
    }
    
    return self;
}

- (void) loadView {
    
    NSLog(@"loading view!");
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.view.backgroundColor = [UIColor redColor];
    self.view.center = CGPointMake(384, 512);
    
    // Rotate into landscape mode.
//    self.view.frame = CGRectMake(0, 0, 768, 1024);

    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    
    
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    testView.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:testView];
    
    // Not a whole hell of a lot to do here. Just make the picker view
    // and throw a button underneath and call it done.
    
    picker = [[UIPickerView alloc] init];
    picker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    NSLog(@"picker center: %@", NSStringFromCGPoint(picker.center));
    
    picker.delegate = self;
    picker.dataSource = self;
    
    [self.view addSubview:picker];
    
    
    selectServerButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    [self.view addSubview:selectServerButton];
}

- (void) viewDidLoad {

    
}


#pragma mark Picker Delegate Methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"selected %@", [servers objectAtIndex:row]);
}


#pragma mark Picker Data Source Methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [servers count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [servers objectAtIndex:row];
}

- (void) dealloc { 
    [super dealloc];
    [servers release];
}

@end
