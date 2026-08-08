//
//  sfFirstViewController.h
//  SF
//
//  Created by Mihailo Despotovic on 2/2/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sfEdition.h"
#import "sfAppDelegate.h"
#import "sfBrowseVC.h"
#import "sfUtil.h"

@interface sfFirstViewController : UIViewController <UITableViewDelegate>

@property IBOutlet UITableView *tableView;

@property IBOutlet UITextView *detail;
@property IBOutlet UIImageView *detailImageView;
@property IBOutlet UILabel *yearsLabel;
@property IBOutlet UILabel *publisherLabel;

@property sfEdition *editionDetails;


@end
