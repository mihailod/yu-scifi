//
//  sfWebVC.m
//  SF
//
//  Created by Mihailo Despotovic on 2/9/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfWebVC.h"

@interface sfWebVC ()

@end

@implementation sfWebVC

@synthesize webView;
@synthesize back;

@synthesize urlString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[[self tabBarController] tabBar] setHidden:true];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender { [webView goBack]; }
- (IBAction)forward:(id)sender {[webView goForward]; }

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [[[self tabBarController] tabBar] setHidden:false];
    }
}

@end
