//
//  SWUserListViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/13/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWUserListViewController.h"
#import "SWUserDetailViewController.h"
#import "SWUserAPI.h"
#import "SWUserCell.h"
#import "SVProgressHUD.h"
#import "SWWebViewController.h"

@interface SWUserListViewController ()

@end

@implementation SWUserListViewController

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
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tv];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)pulledToRefresh:(ODRefreshControl *)control
{
    [self loadNewerUsers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.users || self.users.count == 0) [self loadUsers];
    
    switch (self.feed.type) {
        case SWFeedTypeUserFollowers:
            self.title = @"Followers";
            break;
        case SWFeedTypeUserFollowing:
            self.title = @"Following";
            break;
        default:
            self.title = @"Give me a Title";
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}


- (void)loadUsers
{
    if (self.loadingUsers) return;
    self.loadingUsers = TRUE;
    if (self.users.count == 0) [SVProgressHUD show];
    [self.refreshControl beginRefreshing];
    
    [self.feed loadItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        [self replaceUsersInTableWithUsers:posts];
    }];
}

- (void)loadOlderUsers
{
    if (!self.feed.moreItemsAvailable || self.loadingUsers) return;
    self.loadingUsers = TRUE;
    if (self.users.count == 0) [SVProgressHUD show];
    
   [self.feed loadOlderItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
       [self addUsersToEndOfTable:posts];
   }];
}

- (void)loadNewerUsers
{
    if (self.loadingUsers) return;
    self.loadingUsers = TRUE;
    if (self.users.count == 0) [SVProgressHUD show];
    
    [self.feed loadNewerItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        [self addUsersToBeginningOfTable:posts];
    }];
}

- (void)replaceUsersInTableWithUsers:(NSMutableArray *)users
{
    [self.refreshControl endRefreshing];
    [SVProgressHUD dismiss];
    self.loadingUsers = FALSE;
    
    @synchronized(self.users) {
        self.users = users;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tv reloadData];
    });
}

- (void)addUsersToEndOfTable:(NSMutableArray *)users
{
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    self.loadingUsers = FALSE;
    if (users.count == 0) return;
    
    NSInteger oldUserCount = self.users.count;
    
    @synchronized(self.users) {
        self.users = [[self.users arrayByAddingObjectsFromArray:users] mutableCopy];
    }
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = 0; i < users.count; i++){
        [indexPaths addObject:[NSIndexPath indexPathForRow:oldUserCount + i inSection:0]];
    }
    if (indexPaths.count != users.count){
        [self.tv reloadData];
        return;
    }
    [self.tv beginUpdates];
    if (!self.feed.moreItemsAvailable){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:oldUserCount inSection:0];
        [self.tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tv insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tv endUpdates];
}

- (void)addUsersToBeginningOfTable:(NSMutableArray *)users
{
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    self.loadingUsers = FALSE;
    if (users.count == 0) return;
    
    @synchronized(self.users) {
        self.users = [[users arrayByAddingObjectsFromArray:self.users] mutableCopy];
    }
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = 0; i < users.count; i++){
        [indexPaths addObject:[NSIndexPath indexPathForRow:i  inSection:0]];
    }
    
    [self.tv beginUpdates];
    [self.tv insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.tv endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.users) return 0;
    if (self.feed.moreItemsAvailable) return self.users.count + 1;
    return self.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.users || self.users.count == 0) return 100.0;
    if (indexPath.row >= self.users.count) return 140.0;
    return [SWUserCell shortCellHeightForUser:[self.users objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.feed.moreItemsAvailable && indexPath.row + 15 > self.users.count) [self loadOlderUsers];
    
    DLog(@"%i",indexPath.row);
    if (indexPath.row >= self.users.count) return [self loadingCellForIndexPath:indexPath];
    return [self userCellForIndexPath:indexPath];
}

- (UITableViewCell *)userCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWUserCell";
    SWUserCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell prepareUIWithUser:[self.users objectAtIndex:indexPath.row]];
    
    [cell handleLinkTappedWithBlock:^(NSTextCheckingResult *linkInfo) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWWebViewController *webController = [storyboard instantiateViewControllerWithIdentifier:@"SWWebViewController"];
        webController.initialURL = linkInfo.URL;
        [self.navigationController pushViewController:webController animated:TRUE];
    }];
    
    return cell;
}

- (UITableViewCell *)loadingCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWLoadingPostsCell";
    UITableViewCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row >= self.users.count) return;
    
    NSDictionary *user = [self.users objectAtIndex:indexPath.row];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWUserDetailViewController *threadViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWUserDetailViewController"];
    threadViewController.user = user;
    [self.navigationController pushViewController:threadViewController animated:TRUE];
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
