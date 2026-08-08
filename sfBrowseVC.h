//
//  sfBrowseVC.h
//  SF
//
//  Created by Mihailo Despotovic on 2/3/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sfEdition.h"
#import "sfDetailVC.h"
#import "sfUtil.h"

@interface sfBrowseVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property sfEdition *selectedEdition;
@property IBOutlet UITableView *booksTV;

@end
