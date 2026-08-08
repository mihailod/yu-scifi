//
//  sfDetailVC.h
//  SF
//
//  Created by Mihailo Despotovic on 2/3/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sfBook.h"
#import "sfAppDelegate.h"
#import "sfUtil.h"
#import "sfImageVC.h"

@interface sfDetailVC : UIViewController

@property IBOutlet UIImageView *imageView;
@property IBOutlet UITextView *textView;

@property IBOutlet UIImageView *ser;
@property IBOutlet UIImageView *ser1;
@property IBOutlet UIImageView *cro;
@property IBOutlet UIImageView *slo;
@property IBOutlet UIImageView *bih;

// Google, Wikipedia and the four marketplaces. Connection order is not
// meaningful; the layout code sorts these by tag, which is also the index into
// sfData's webSearchSyntax array.
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *linkButtons;

- (IBAction) followWebLink:(id)sender;

@property sfBook *book;

@end
