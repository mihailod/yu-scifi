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

- (IBAction) followWebLink:(id)sender;

@property sfBook *book;

@end
