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
    titleLabel.text = [sfUtil appNameAndVersion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rate:(id)sender { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[sfUtil appStoreUrl]]]; }

- (IBAction)emailDeveloper:(id)sender { [self sendEmail:EMAIL_DEV withBody:@""]; }

- (IBAction)emailFriend:(id)sender {
    NSString *body = [NSString stringWithFormat:@"Razgledaj preko 500 retro domaćih SF knjiga (Polaris, Kentaur, Znak Sagite, itd.) uz pomoć %@ aplikacije: %@", [sfUtil appName], [sfUtil appStoreUrl]];
    [self sendEmail:@"" withBody:body];
}

- (void)sendEmail:(NSString *)to withBody:(NSString*)body
{
    NSString *subject = [sfUtil appName];
    NSArray *toAddresses = [NSArray arrayWithObject:to];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:subject];
    [mc setMessageBody:body isHTML:NO];
    [mc setToRecipients:toAddresses];
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    /*switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }*/
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)facebook:(id)sender
{
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setMessage:@"Fesjbuk nije podešen"];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString *fbTxt = [NSString stringWithFormat:@"Razgledam >500 domaćih retro SF knjiga (Polaris, Kentaur, Znak Sagite, itd.) uz pomoć %@ aplikacije: %@", [sfUtil appName], [sfUtil appStoreUrl]];
    [vc setInitialText:fbTxt];
    [self presentViewController:vc animated:YES completion:NULL];
}

- (IBAction)twitter:(id)sender
{
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setMessage:@"Tviter nije podešen"];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *tTxt = [NSString stringWithFormat:@"Razgledam >500 domaćih retro SF knjiga (Polaris, Kentaur, Znak Sagite, itd.) uz pomoć %@ aplikacije: %@", [sfUtil appName], [sfUtil appStoreUrl]];
    [vc setInitialText:tTxt];
    [self presentViewController:vc animated:YES completion:NULL];
}

- (IBAction)donate:(id)sender { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_PAYPAL]]; }

@end
