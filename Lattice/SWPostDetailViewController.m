//
//  SWPostDetailViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/12/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWPostDetailViewController.h"
#import "SWUserDetailViewController.h"
#import "SWWebViewController.h"
#import "SWPostCell.h"
#import "SWActionCell.h"
#import "SWPostAPI.h"
#import "SVProgressHUD.h"

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
    return 84.0;
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
    //NSLog(@"POST! %@", self.post);
    static NSString *CellIdentifier = @"SWPostCell";
    SWPostCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.profileButton.tag = indexPath.row;
    [cell.profileButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.profileButton addTarget:self action:@selector(profilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell handleLinkTappedWithBlock:^(NSTextCheckingResult *linkInfo) {
        NSString *firstCharacter = [[linkInfo.URL absoluteString] substringToIndex:1];
        if ([firstCharacter isEqualToString:@"@"]) {
            NSString *userID = [linkInfo.URL absoluteString];
            [self performSegueWithIdentifier:@"SWPostDetailToUserDetail" sender:userID];
        } else if ([firstCharacter isEqualToString:@"#"]) {
            NSLog(@"Hash Tag!");
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWWebViewController *webController = [storyboard instantiateViewControllerWithIdentifier:@"SWWebViewController"];
            webController.initialURL = linkInfo.URL;
            [self.navigationController pushViewController:webController animated:TRUE];
        }
    }];
    
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
    
    [cell prepareUIWithPost:self.post];
    
    [cell.replyButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.replyButton addTarget:self action:@selector(replyPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.repostButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.repostButton addTarget:self action:@selector(repostPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.starButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.starButton addTarget:self action:@selector(starPressed) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)replyPressed
{
    NSLog(@"Reply");
}

- (void)repostPressed
{    
    [SVProgressHUD show];
    if ([[self.post objectForKey:@"you_reposted"] intValue] == 1) {
        [SWPostAPI unrepostPostID:[self.post objectForKey:@"id"] completed:^(NSError *error, NSDictionary *post, NSDictionary *metadata) {
            //returned post is the old one.
            self.post = post;
            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    } else {
        [SWPostAPI repostPostID:[self.post objectForKey:@"id"] completed:^(NSError *error, NSDictionary *post, NSDictionary *metadata) {
            //returned post is the new one. We want to refresh the old.
            self.post = [post objectForKey:@"repost_of"];

            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    }
}

- (void)starPressed
{
    [SVProgressHUD show];
    if ([[self.post objectForKey:@"you_starred"] intValue] == 1) {
        [SWPostAPI unstarPostID:[self.post objectForKey:@"id"] completed:^(NSError *error, NSDictionary *post, NSDictionary *metadata) {
            self.post = post;
            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    } else {
        [SWPostAPI starPostID:[self.post objectForKey:@"id"] completed:^(NSError *error, NSDictionary *post, NSDictionary *metadata) {
            self.post = post;
            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    }

}

- (void)profilePressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"SWPostDetailToUserDetail" sender:[self.post objectForKey:@"user"]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWPostDetailToUserDetail"]) {
        SWUserDetailViewController *destinationView = segue.destinationViewController;
        if ([sender isKindOfClass:[NSString class]]) destinationView.userID = (NSString *)sender;
        if ([sender isKindOfClass:[NSDictionary class]]) destinationView.user = (NSDictionary *)sender;
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
