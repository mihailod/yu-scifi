//
//  sfImageVC.m
//  SF
//
//  Created by Mihailo Despotovic on 2/21/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfImageVC.h"

@interface sfImageVC ()

@end

@implementation sfImageVC

@synthesize imageView;
@synthesize image;

// Previously this screen carried two image views and switched between them on a
// screen-height check for the 4-inch iPhone 5. That test is false on every
// current device, so the cover was always laid out for a 3.5-inch screen. One
// aspect-fit view that tracks the view bounds handles every size instead.
- (void)awakeFromNib
{
    [super awakeFromNib];
    // Give the cover the whole screen; set before the push to animate correctly.
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
