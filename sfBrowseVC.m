//
//  sfBrowseVC.m
//  SF
//
//  Created by Mihailo Despotovic on 2/3/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfBrowseVC.h"

@interface sfBrowseVC ()

@end

@implementation sfBrowseVC

@synthesize selectedEdition;
@synthesize booksTV;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [sfUtil applyAdaptiveColors:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [selectedEdition.books count]; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sfBook *book = [selectedEdition.books objectAtIndex:[indexPath row]];
    return [sfUtil makeBookCell:indexPath tableView:tableView book:book];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"BrowseToDetail" sender:nil];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    sfDetailVC *detailVC = (sfDetailVC*)[segue destinationViewController];
    detailVC.book = [selectedEdition.books objectAtIndex:[[booksTV indexPathForSelectedRow] row]];
    [[segue destinationViewController] setTitle:detailVC.book.naslov];
}


@end
