//
//  SWPostDetailViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWPostDetailViewController.h"
#import "SWUserDetailViewController.h"
#import "SWPostCell.h"
#import "SWActionCell.h"


@interface SWPostDetailViewController ()

@end

@implementation SWPostDetailViewController

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
    self.tv.tableFooterView = [UIView new];
    self.tv.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return [SWPostCell heightForPost:self.post];
    return 64.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [self postCellForIndexPath:indexPath];
        case 1:
            return [self actionCell];
        default:
            return [UITableViewCell new];
    }
}


- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWPostCell";
    SWPostCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.profileButton.tag = indexPath.row;
    [cell.profileButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.profileButton addTarget:self action:@selector(profilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell prepareUIWithPost:self.post];
    
    return cell;
}

- (UITableViewCell *)actionCell
{
    static NSString *CellIdentifier = @"SWActionCell";
    SWActionCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    return cell;
}

- (void)profilePressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"SWPostDetailToUserDetail" sender:[self.post objectForKey:@"user"]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWPostDetailToUserDetail"]) {
        SWUserDetailViewController *destinationView = segue.destinationViewController;
        destinationView.user = (NSDictionary *)sender;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
