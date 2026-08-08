//
//  sfInfoVC.h
//  SF
//
//  Created by Mihailo Despotovic on 2/12/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>

#import "sfUtil.h"
#import "sfData.h"
#import "sfWebVC.h"

@interface sfInfoVC : UIViewController <MFMailComposeViewControllerDelegate>

@property IBOutlet UILabel *titleLabel;

- (IBAction)rate:(id)sender;
- (IBAction)emailDeveloper:(id)sender;
- (IBAction)emailFriend:(id)sender;
- (IBAction)facebook:(id)sender;
- (IBAction)twitter:(id)sender;
- (IBAction)donate:(id)sender;

    
@end
