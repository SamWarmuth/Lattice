//
//  SWUserDetailViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWUserDetailViewController.h"
#import "SWFeedViewController.h"
#import "SWWebViewController.h"
#import "SWUserListViewController.h"
#import "SWUserCell.h"
#import "SWActionCell.h"
#import "SWUserAPI.h"
#import "SVProgressHUD.h"

@interface SWUserDetailViewController ()

@end

@implementation SWUserDetailViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateFollowButton];
    if (!self.user && self.userID){
        [self loadUser];
    }
}

- (void)loadUser
{
    if (!self.user && !self.userID) return;
        
    self.loadingUser = TRUE;
    [SVProgressHUD show];
    if (self.user) self.userID = self.user.id;

    [SWUserAPI getUserWithID:self.userID completed:^(NSError *error, NSDictionary *userDict, NSDictionary *metadata) {
        self.loadingUser = FALSE;
        [SVProgressHUD dismiss];
        @synchronized(self.user) {
            self.user = [User createOrUpdateUserFromDictionary:userDict];
        }
        [self.tv reloadData];
        [self updateFollowButton];
    }];
}

- (void)updateFollowButton
{
    self.followButton.enabled = !!self.user;
    if (!self.user) return;
    
    if (self.user.you_follow){
        self.followButton.title = @"Unfollow";
    } else if (self.user.you_follow == nil){
        self.followButton.enabled = FALSE;
        self.followButton.title = @"You";
    } else {
        self.followButton.title = @"Follow";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.user) return 0;
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return [SWUserCell heightForUser:self.user];
    return 140.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [self userCellForIndexPath:indexPath];
        case 1:
            return [self actionCell];
        default:
            return [UITableViewCell new];
    }
}

- (UITableViewCell *)userCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWUserCell";
    SWUserCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell prepareUIWithUser:self.user];
    
    [cell handleLinkTappedWithBlock:^(NSTextCheckingResult *linkInfo) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWWebViewController *webController = [storyboard instantiateViewControllerWithIdentifier:@"SWWebViewController"];
        webController.initialURL = linkInfo.URL;
        [self.navigationController pushViewController:webController animated:TRUE];
    }];
    
    return cell;
}

- (UITableViewCell *)actionCell
{
    static NSString *CellIdentifier = @"SWUserActionCell";
    SWActionCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell prepareUIWithUser:self.user];
    
    [cell.postsButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.postsButton addTarget:self action:@selector(viewPosts) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.starredButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.starredButton addTarget:self action:@selector(viewStarred) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.followingButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.followingButton addTarget:self action:@selector(viewFollowing) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.followersButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.followersButton addTarget:self action:@selector(viewFollowers) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)viewPosts
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
    feedViewController.feed = [SWFeed feedWithType:SWFeedTypeUserPosts keyID:self.user.id];
    [self.navigationController pushViewController:feedViewController animated:TRUE];
}

- (void)viewStarred
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
    feedViewController.feed = [SWFeed feedWithType:SWFeedTypeUserStars keyID:self.user.id];
    [self.navigationController pushViewController:feedViewController animated:TRUE];
}

- (void)viewFollowing
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWUserListViewController *userListViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWUserListViewController"];
    userListViewController.feed = [SWFeed feedWithType:SWFeedTypeUserFollowing keyID:self.user.id];
    [self.navigationController pushViewController:userListViewController animated:TRUE];
}

- (void)viewFollowers
{    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWUserListViewController *userListViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWUserListViewController"];
    userListViewController.feed = [SWFeed feedWithType:SWFeedTypeUserFollowers keyID:self.user.id];
    [self.navigationController pushViewController:userListViewController animated:TRUE];
}

- (IBAction)followButtonPressed:(id)sender
{
    if ([self.user.you_follow intValue] == 1){
        DLog(@"un.");
        [SVProgressHUD show];
        self.loadingUser = TRUE;
        if (!self.userID) self.userID = self.user.id;
        [SWUserAPI unfollowUserID:self.userID completed:^(NSError *error, NSDictionary *userDict, NSDictionary *metadata) {
            [SVProgressHUD dismiss];
            self.loadingUser = FALSE;
            @synchronized(self.user) {
                self.user = [User createOrUpdateUserFromDictionary:userDict];
            }
            [self.tv reloadData];
            [self updateFollowButton];
        }];        
    } else {
        DLog(@"follow.");
        
        [SVProgressHUD show];
        self.loadingUser = TRUE;
        if (!self.userID) self.userID = self.user.id;
        [SWUserAPI followUserID:self.userID completed:^(NSError *error, NSDictionary *userDict, NSDictionary *metadata) {
            [SVProgressHUD dismiss];
            self.loadingUser = FALSE;
            @synchronized(self.user) {
                self.user = [User createOrUpdateUserFromDictionary:userDict];
            }
            [self.tv reloadData];
            [self updateFollowButton];

            
        }];
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
