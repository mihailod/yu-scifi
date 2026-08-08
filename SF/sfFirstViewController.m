//
//  sfFirstViewController.m
//  SF
//
//  Created by Mihailo Despotovic on 2/2/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfFirstViewController.h"

@interface sfFirstViewController ()

@end

@implementation sfFirstViewController

@synthesize tableView;

@synthesize detailImageView;
@synthesize detail;
@synthesize yearsLabel;
@synthesize publisherLabel;

@synthesize editionDetails;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (editionDetails) {
        detail.text = editionDetails.info;
        [self setTitle:editionDetails.name];
        [[self detailImageView] setImage:editionDetails.image];
        yearsLabel.text = editionDetails.yearsActive;
        publisherLabel.text = editionDetails.publisher;
        [self buildEditionDetailLayout];
    } else {
        sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self navigationItem].title = [NSString stringWithFormat:@"%lu kategorija      %d knjiga", (unsigned long)[[[appDelegate data] allEditions] count], [[appDelegate data] totalNumberOfItems]];
    }
    [sfUtil applyAdaptiveColors:self.view];
}

// This scene used a 2014 fixed-frame layout sized for a 320pt screen, and its
// body text was left at 14pt -- the code that meant to resize it called
// [UIFont fontWithName:@"System" ...], which returns nil (there is no family by
// that name), so it silently cleared the font instead. Rebuilt against the safe
// area with the description taking everything below the header.
- (void)buildEditionDetailLayout
{
    detailImageView.translatesAutoresizingMaskIntoConstraints = NO;
    yearsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    publisherLabel.translatesAutoresizingMaskIntoConstraints = NO;
    detail.translatesAutoresizingMaskIntoConstraints = NO;

    yearsLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    yearsLabel.textAlignment = NSTextAlignmentLeft;
    publisherLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    // Single-line with tail truncation lost the end of the longer imprints
    // ("Narodna Knjiga i Dečje Novine, Gornji Milanovac"). Let it wrap, and
    // left-align to match the years label and the description below.
    publisherLabel.numberOfLines = 0;
    publisherLabel.lineBreakMode = NSLineBreakByWordWrapping;
    publisherLabel.textAlignment = NSTextAlignmentLeft;
    // Prose, so regular rather than bold -- eight lines of bold body copy reads heavy.
    detail.font = [UIFont systemFontOfSize:20.0f];
    detail.textContainerInset = UIEdgeInsetsZero;
    detail.textContainer.lineFragmentPadding = 0;

    // Edition name is this screen's navigation title. Copy the bar's existing
    // appearance so only the font changes, and set it on navigationItem rather
    // than the bar itself so it stays scoped to this screen.
    UINavigationBarAppearance *ap = [self.navigationController.navigationBar.standardAppearance copy];
    if (ap == nil) {
        ap = [[UINavigationBarAppearance alloc] init];
        [ap configureWithDefaultBackground];
    }
    ap.titleTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:21.0f],
                                NSForegroundColorAttributeName : [UIColor labelColor] };
    self.navigationItem.standardAppearance = ap;
    self.navigationItem.scrollEdgeAppearance = ap;
    self.navigationItem.compactAppearance = ap;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [detailImageView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [detailImageView.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [detailImageView.widthAnchor constraintEqualToAnchor:safe.widthAnchor multiplier:0.24],
        [detailImageView.heightAnchor constraintEqualToAnchor:detailImageView.widthAnchor multiplier:1.36],

        [yearsLabel.leadingAnchor constraintEqualToAnchor:detailImageView.trailingAnchor constant:16],
        [yearsLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [yearsLabel.centerYAnchor constraintEqualToAnchor:detailImageView.centerYAnchor],

        [publisherLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [publisherLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [publisherLabel.topAnchor constraintEqualToAnchor:detailImageView.bottomAnchor constant:16],

        [detail.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [detail.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [detail.topAnchor constraintEqualToAnchor:publisherLabel.bottomAnchor constant:16],
        [detail.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-12],
    ]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    unsigned long row = [indexPath row];
    sfFirstViewController *c =[self.storyboard instantiateViewControllerWithIdentifier:@"editionDetail"];
    sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
    sfEdition *e = [appDelegate.data.allEditions objectAtIndex:row];
    c.editionDetails = e;
    [self.navigationController pushViewController:c animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [[[appDelegate data] allEditions] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
    sfEdition *e = [appDelegate.data.allEditions objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:@"Cell" /*forIndexPath:indexPath*/];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    //cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    NSString *name = e.name;
    cell.textLabel.text = name;
    
    // add the image in a custom way so all images are the same size
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 33, 45)];
    imgView.backgroundColor=[UIColor clearColor];
    //[imgView.layer setCornerRadius:1.0f]; // rounded rectangles!
    [imgView.layer setMasksToBounds:YES];
    [imgView setImage:e.image];   
    [cell.contentView addSubview:imgView];
    [cell setIndentationLevel:4]; // move text a bit since the image is layed in a custom way
    
    unsigned long number = [e.books count];
    NSString *detailsTxt = e.yearsActive;
    NSString *txt = [NSString stringWithFormat:@"%@ (%lu)", detailsTxt, number];
    cell.detailTextLabel.text = txt;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EditionsToBrowse" sender:nil];
}

# pragma segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
    sfEdition *e = [appDelegate.data.allEditions objectAtIndex:[indexPath row]];
    [[segue destinationViewController] setTitle:e.name];
    sfBrowseVC *destinationVC = (sfBrowseVC *)[segue destinationViewController];
    destinationVC.selectedEdition = [[[appDelegate data] allEditions] objectAtIndex:[indexPath row]];
}

@end
