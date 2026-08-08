//
//  sfSearchViewController.h
//  SF
//
//  Created by Mihailo Despotovic on 2/2/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sfAppDelegate.h"
#import "sfDetailVC.h"
#import "sfUtil.h"

@interface sfSecondViewController : UIViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;

@end
