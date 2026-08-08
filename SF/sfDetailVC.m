//
//  sfDetailVC.m
//  SF
//
//  Created by Mihailo Despotovic on 2/3/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfDetailVC.h"
#import <SafariServices/SafariServices.h>

@interface sfDetailVC ()

@end

@implementation sfDetailVC

@synthesize imageView;
@synthesize textView;
@synthesize book;

@synthesize ser;
@synthesize ser1;
@synthesize cro;
@synthesize slo;

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
    [imageView setImage:[book image]];
    [textView setText:[self formatDetailText]];
    [ser.layer setBorderColor:  [[UIColor blackColor] CGColor]]; [ser.layer  setBorderWidth: 0.5];
    [ser1.layer setBorderColor: [[UIColor blackColor] CGColor]]; [ser1.layer setBorderWidth: 0.5];
    [cro.layer setBorderColor:  [[UIColor blackColor] CGColor]]; [cro.layer  setBorderWidth: 0.5];
    [slo.layer setBorderColor:  [[UIColor blackColor] CGColor]]; [slo.layer  setBorderWidth: 0.5];
    if (!IS_IPHONE_5) {
        [textView setFont:[UIFont fontWithName:@"System" size:10.0f]];
    }
}

// Presented with SFSafariViewController rather than an in-app web view. It runs
// out-of-process on the real Safari engine, so it sends Safari's user agent and
// shares Safari's cookie jar -- the Balkan marketplaces sit behind Cloudflare,
// which bot-scores a legacy UIWebView UA and throws up a "verify you are human"
// interstitial. It also sidesteps ATS and gives us Reader/Share for free.
- (IBAction) followWebLink:(id)sender;
{
    sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *urlString = [sfUtil makeWebLink:(int)[sender tag] book:book webSearchSyntax:[[appDelegate data] webSearchSyntax]];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) { return; }
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:url];
    sfvc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (NSString *)formatDetailText
{
    bool tweak = [[book edicija] isEqualToString:EDITION_OSTALO] || [[book edicija] isEqualToString:EDITION_TEORIJA];
    
    NSString *txt = book.naslov;
    txt = [txt stringByAppendingString:@"\n"];
    if (book.title.length > 0) {
        txt = [txt stringByAppendingString:book.title];
        txt = [txt stringByAppendingString:@"\n\n"];
    } else {
        txt = [txt stringByAppendingString:@"\n"];
    }
    
    txt = [txt stringByAppendingString:book.autor];
    txt = [txt stringByAppendingString:@", "];
    txt = [txt stringByAppendingString:book.yearWritten];
    txt = [txt stringByAppendingString:@"\n"];
    if (book.author.length > 0) {
        txt = [txt stringByAppendingString:book.author];
        txt = [txt stringByAppendingString:@"\n\n"];
    } else {
        txt = [txt stringByAppendingString:@"\n"];
    }
    
    if (tweak) {
        txt = [txt stringByAppendingString:book.serija];
    } else {
        txt = [txt stringByAppendingString:book.edicija];
    }
    txt = [txt stringByAppendingString:@", "];
    txt = [txt stringByAppendingString:book.godinaIzdanja];
    if (book.prevodilac.length > 0) {
        txt = [txt stringByAppendingString:@", "];
        txt = [txt stringByAppendingString:book.prevodilac];
    }
    
    if (book.serija.length > 0 && !tweak) {
        txt = [txt stringByAppendingString:@"\n\n"];
        txt = [txt stringByAppendingString:book.serija];
        txt = [txt stringByAppendingString:@"\n"];
        txt = [txt stringByAppendingString:book.serial];
    }
    
    return txt;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch view] == imageView) {
        sfImageVC *i =[self.storyboard instantiateViewControllerWithIdentifier:@"imageVC"];
        i.image = book.image;
        [self.navigationController pushViewController:i animated:YES];
    }
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end
