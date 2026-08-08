//
//  sfSearchViewController.m
//
//  Created by Mihailo Despotovic on 2/2/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfSecondViewController.h"

@interface sfSecondViewController ()

@end

@implementation sfSecondViewController

@synthesize searchResults;
@synthesize searchTableView;
@synthesize searchBar;

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

    // The storyboard pins the search bar at y=64, which sat just under the 2014
    // navigation bar. Modern nav bars are taller, so it ended up behind one and
    // could not be tapped at all. Pinned to the safe area instead; the table
    // taking the safe-area bottom also keeps rows clear of the floating tab bar.
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    searchTableView.translatesAutoresizingMaskIntoConstraints = NO;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [searchBar.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [searchBar.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [searchBar.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],

        [searchTableView.topAnchor constraintEqualToAnchor:searchBar.bottomAnchor],
        [searchTableView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [searchTableView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [searchTableView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
    ]];

    [sfUtil applyAdaptiveColors:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma search delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText { [self refreshSearch:searchText]; }
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar { [searchBar resignFirstResponder]; }

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    NSString *text = [searchBar text];
    [self refreshSearch:text];
}

- (void)refreshSearch:(NSString *)text {
    sfAppDelegate *appDelegate = (sfAppDelegate *)[[UIApplication sharedApplication] delegate];
    searchResults = [[appDelegate data] search:text];
    // Reload synchronously. This used to be performSelectorOnMainThread: with
    // waitUntilDone:NO, but the search bar delegate already runs on the main
    // thread, so that did not hop threads -- it deferred the reload to a later
    // runloop pass. In the gap searchResults had already shrunk while the table
    // still held the old row count, so a layout pass could ask for a row past
    // the end of the array and crash in cellForRowAtIndexPath.
    [searchTableView reloadData];
}

# pragma table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return searchResults.count; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Belt and braces alongside the synchronous reload above: results are
    // replaced wholesale on every keystroke, so if the table ever asks for a row
    // it cached before a shrink, degrade to a blank cell instead of trapping.
    if (indexPath.row >= (NSInteger)searchResults.count) {
        return [sfUtil makeBookCell:indexPath tableView:tableView book:[[sfBook alloc] init]];
    }
    sfBook *book = searchResults[indexPath.row];
    return [sfUtil makeBookCell:indexPath tableView:tableView book:book];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SearchToDetail" sender:nil];
}

# pragma segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.searchTableView indexPathForSelectedRow];
    if (indexPath == nil || indexPath.row >= (NSInteger)searchResults.count) { return; }
    sfBook *b = searchResults[indexPath.row];
    [[segue destinationViewController] setTitle:b.naslov];
    sfDetailVC *detailVC = (sfDetailVC*)[segue destinationViewController];
    detailVC.book = b;
}

@end

