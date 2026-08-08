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
@synthesize bih;

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
    // Fixed mid grey rather than separatorColor: this is a CALayer border, and
    // CGColor does not re-resolve when the appearance changes. 50% grey holds an
    // outline against both a white and a dark backdrop.
    CGColorRef flagBorder = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
    for (UIImageView *flag in [self orderedFlags]) {
        [flag.layer setBorderColor:flagBorder];
        [flag.layer setBorderWidth:0.5];
    }

    [sfUtil applyAdaptiveColors:self.view];
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
// Flags in marketplace tag order: Limundo and Kupindo are Serbian, Njuskalo
// Croatian, Bolha Slovenian, Pik/olx Bosnian.
- (NSArray *)orderedFlags
{
    return @[ser, ser1, cro, slo, bih];
}

- (void)buildAdaptiveLayout
{
    NSArray *btns = [self.linkButtons sortedArrayUsingComparator:^NSComparisonResult(UIButton *a, UIButton *b) {
        return [@(a.tag) compare:@(b.tag)];
    }];
    NSArray *flags = [self orderedFlags];

    // Tags below LIMUNDO are the plain reference links (Google, Wikipedia,
    // Goodreads); from LIMUNDO on, each link is paired with a country flag.
    // Deriving both counts from the tags keeps this correct if a link is added.
    NSUInteger plainCount = LIMUNDO;
    if (btns.count != plainCount + flags.count) { return; }   // storyboard changed -- leave the nib layout alone

    const CGFloat kRowHeight    = 30.0f;   // every row, so gaps read evenly
    const CGFloat kRowSpacing   = 10.0f;   // between rows inside a group
    const CGFloat kGroupSpacing = 26.0f;   // between the two groups

    NSMutableArray *referenceRows = [NSMutableArray array];
    for (NSUInteger i = 0; i < plainCount; i++) { [referenceRows addObject:btns[i]]; }

    NSMutableArray *marketRows = [NSMutableArray array];
    for (NSUInteger i = 0; i < flags.count; i++) {
        UIImageView *flag = flags[i];
        [flag.widthAnchor constraintEqualToConstant:30].active = YES;
        [flag.heightAnchor constraintEqualToConstant:15].active = YES;
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[flag, btns[plainCount + i]]];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.alignment = UIStackViewAlignmentCenter;
        row.spacing = 8;
        [marketRows addObject:row];
    }

    // A bare UIButton and a flag+button row do not have the same intrinsic
    // height, so a single stack with uniform spacing still looked ragged.
    // Pinning every row to one height makes the spacing uniform by construction.
    for (UIView *row in [referenceRows arrayByAddingObjectsFromArray:marketRows]) {
        [row.heightAnchor constraintEqualToConstant:kRowHeight].active = YES;
    }

    UIStackView *referenceGroup = [[UIStackView alloc] initWithArrangedSubviews:referenceRows];
    UIStackView *marketGroup    = [[UIStackView alloc] initWithArrangedSubviews:marketRows];
    for (UIStackView *group in @[referenceGroup, marketGroup]) {
        group.axis = UILayoutConstraintAxisVertical;
        group.alignment = UIStackViewAlignmentLeading;
        group.spacing = kRowSpacing;
    }

    UIStackView *links = [[UIStackView alloc] initWithArrangedSubviews:@[referenceGroup, marketGroup]];
    links.axis = UILayoutConstraintAxisVertical;
    links.alignment = UIStackViewAlignmentLeading;
    links.spacing = kGroupSpacing;
    links.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:links];

    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.translatesAutoresizingMaskIntoConstraints = NO;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    // Let the link column shrink to the width of its longest label rather than
    // taking a fixed share, so whatever is left over goes to the cover. Without
    // this the column kept a slab of empty space to the right of "Njuskalo".
    [links setContentHuggingPriority:999 forAxis:UILayoutConstraintAxisHorizontal];
    [links setContentCompressionResistancePriority:UILayoutPriorityRequired
                                           forAxis:UILayoutConstraintAxisHorizontal];

    // Cover spans from the leading margin to the link column, keeping a book-ish
    // 1:1.45 ratio, so its width is whatever the links do not need.
    [NSLayoutConstraint activateConstraints:@[
        [imageView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:12],
        [imageView.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [imageView.trailingAnchor constraintEqualToAnchor:links.leadingAnchor constant:-12],
        [imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor multiplier:1.45],

        [links.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-12],
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
    int tag = (int)[sender tag];

    // Goodreads carries reviews under both the original and the translated
    // title, and they are usually different sets of readers, so let the user
    // choose rather than picking for them. Only worth asking when we actually
    // hold two distinct titles.
    if (tag == GOODREADS && book.title.length > 0 && book.naslov.length > 0
        && ![book.title isEqualToString:book.naslov]) {
        UIAlertController *sheet =
            [UIAlertController alertControllerWithTitle:@"Goodreads"
                                                message:@"Traži po naslovu:"
                                         preferredStyle:UIAlertControllerStyleActionSheet];

        __weak typeof(self) weakSelf = self;
        NSString *original = book.title;
        NSString *translated = book.naslov;

        [sheet addAction:[UIAlertAction actionWithTitle:original
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *a) {
            [weakSelf openWebLinkForTag:GOODREADS keyword:original];
        }]];
        [sheet addAction:[UIAlertAction actionWithTitle:translated
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *a) {
            [weakSelf openWebLinkForTag:GOODREADS keyword:translated];
        }]];
        [sheet addAction:[UIAlertAction actionWithTitle:@"Otkaži"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];

        // Required if this ever runs in a regular size class, where an action
        // sheet is presented as a popover and needs an anchor.
        sheet.popoverPresentationController.sourceView = (UIView *)sender;
        sheet.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;

        [self presentViewController:sheet animated:YES completion:nil];
        return;
    }

    [self openWebLinkForTag:tag keyword:nil];
}

// keyword nil means "use the default original/translated rule for this tag".
- (void)openWebLinkForTag:(int)tag keyword:(NSString *)keyword
{
    sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *syntax = [[appDelegate data] webSearchSyntax];
    NSString *urlString = keyword.length > 0
        ? [sfUtil makeWebLink:tag keyword:keyword webSearchSyntax:syntax]
        : [sfUtil makeWebLink:tag book:book webSearchSyntax:syntax];

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
