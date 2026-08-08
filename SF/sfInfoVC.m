//
//  sfInfoVC.m
//  SF
//
//  Created by Mihailo Despotovic on 2/12/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfInfoVC.h"

@interface sfInfoVC ()

@end

@implementation sfInfoVC

@synthesize titleLabel;
@synthesize iconView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    titleLabel.text = [sfUtil appNameAndVersion];
    [sfUtil applyAdaptiveColors:self.view];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // Rounded here rather than in viewDidLoad: bounds are not final until layout,
    // so a radius computed earlier would be wrong on a stretched frame.
    iconView.layer.cornerRadius = iconView.bounds.size.width * 0.2237f;
    iconView.layer.cornerCurve = kCACornerCurveContinuous;
    iconView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
