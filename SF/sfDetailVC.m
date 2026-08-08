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

    // The text view's background is hard-coded white in the storyboard, so pin
    // the colour too -- the inherited default is labelColor, which turns white
    // in dark mode and would leave white text on white.
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont boldSystemFontOfSize:20.0f];

    for (UIButton *b in self.linkButtons) {
        b.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        // Trailing chevron marks these as leaving the app for a browser, and
        // matches the disclosure indicators used in the book lists.
        NSString *t = [b titleForState:UIControlStateNormal];
        if (t.length > 0 && ![t hasSuffix:@"›"]) {
            [b setTitle:[t stringByAppendingString:@" ›"] forState:UIControlStateNormal];
        }
    }

    [self buildAdaptiveLayout];
}

// The storyboard positions this scene with 2014 fixed frames: the cover was set
// to grow with the view while the link buttons were pinned, so on any screen
// wider than 320pt the cover expanded right and covered them. Rebuilt here
// against the safe area so the two columns keep their relationship at any size.
- (void)buildAdaptiveLayout
{
    NSArray *btns = [self.linkButtons sortedArrayUsingComparator:^NSComparisonResult(UIButton *a, UIButton *b) {
        return [@(a.tag) compare:@(b.tag)];
    }];
    if (btns.count != 6) { return; }   // storyboard changed -- leave the nib layout alone

    NSArray *flags = @[ser, ser1, cro, slo];

    NSMutableArray *rows = [NSMutableArray arrayWithObjects:btns[0], btns[1], nil];
    for (NSUInteger i = 0; i < flags.count; i++) {
        UIImageView *flag = flags[i];
        [flag.widthAnchor constraintEqualToConstant:30].active = YES;
        [flag.heightAnchor constraintEqualToConstant:15].active = YES;
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[flag, btns[i + 2]]];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.alignment = UIStackViewAlignmentCenter;
        row.spacing = 8;
        [rows addObject:row];
    }

    UIStackView *links = [[UIStackView alloc] initWithArrangedSubviews:rows];
    links.axis = UILayoutConstraintAxisVertical;
    links.alignment = UIStackViewAlignmentLeading;
    links.spacing = 8;
    links.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:links];

    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.translatesAutoresizingMaskIntoConstraints = NO;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    // Cover keeps a book-ish 1:1.45 ratio at a fixed fraction of the width.
    [NSLayoutConstraint activateConstraints:@[
        [imageView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [imageView.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [imageView.widthAnchor constraintEqualToAnchor:safe.widthAnchor multiplier:0.44],
        [imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor multiplier:1.45],

        [links.leadingAnchor constraintEqualToAnchor:imageView.trailingAnchor constant:16],
        [links.trailingAnchor constraintLessThanOrEqualToAnchor:safe.trailingAnchor constant:-16],
        [links.topAnchor constraintEqualToAnchor:imageView.topAnchor],

        [textView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:12],
        [textView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-12],
        [textView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-12],
        // Clears whichever column is taller.
        [textView.topAnchor constraintGreaterThanOrEqualToAnchor:imageView.bottomAnchor constant:12],
        [textView.topAnchor constraintGreaterThanOrEqualToAnchor:links.bottomAnchor constant:12],
    ]];

    // Breaks the tie the two >= constraints above leave open, so the text hugs
    // the taller column instead of floating at an arbitrary satisfying position.
    NSLayoutConstraint *hug = [textView.topAnchor constraintEqualToAnchor:imageView.bottomAnchor constant:12];
    hug.priority = UILayoutPriorityDefaultHigh;
    hug.active = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self centreDetailText];
}

// The text view spans everything below the cover, so short entries sat pinned to
// its top with a large gap underneath. Padding the top of the text container
// centres the block optically. Done this way rather than by shrinking the view
// so scrolling still works: for the longest entries -- the ones carrying series
// information -- slack goes negative, the inset stays 0 and the text scrolls
// from the top as before.
- (void)centreDetailText
{
    if (textView.text.length == 0 || textView.font == nil) { return; }

    CGFloat pad = textView.textContainer.lineFragmentPadding;
    CGFloat w = CGRectGetWidth(textView.bounds) - (pad * 2.0);
    if (w <= 0) { return; }

    // Measured off the string rather than -sizeThatFits: so this does not mutate
    // the view it is measuring, which would re-trigger layout on every pass.
    CGRect r = [textView.text boundingRectWithSize:CGSizeMake(w, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{ NSFontAttributeName : textView.font }
                                           context:nil];

    CGFloat slack = CGRectGetHeight(textView.bounds) - CGRectGetHeight(r);
    CGFloat top = slack > 0.0 ? floor(slack / 2.0) : 0.0;

    if (fabs(textView.textContainerInset.top - top) > 0.5) {
        textView.textContainerInset = UIEdgeInsetsMake(top, 0, 0, 0);
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
