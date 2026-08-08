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
        self.automaticallyAdjustsScrollViewInsets = NO;
        detail.text = editionDetails.info;
        [self setTitle:editionDetails.name];
        [[self detailImageView] setImage:editionDetails.image];
        yearsLabel.text = editionDetails.yearsActive;
        publisherLabel.text = editionDetails.publisher;
        if (!IS_IPHONE_5) {
            [detail setFont:[UIFont fontWithName:@"System" size:12.0f]];
        }
    } else {
        sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self navigationItem].title = [NSString stringWithFormat:@"%lu kategorija      %d knjiga", (unsigned long)[[[appDelegate data] allEditions] count], [[appDelegate data] totalNumberOfItems]];
    }
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
