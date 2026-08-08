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
@synthesize imageView35;
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (IS_IPHONE_5) {
            [imageView setHidden:true];
            [imageView35 setHidden:false];
        } else {
            [imageView setHidden:false];
            [imageView35 setHidden:true];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (IS_IPHONE_5) {
        [imageView setImage:image];
    } else {
        [imageView35 setImage:image];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
