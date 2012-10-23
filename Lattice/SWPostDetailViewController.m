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
#import "SWComposeViewController.h"
#import "SWAnnotationView.h"
#import "SWAnnotationCell.h"
#import "User.h"
#import "Post.h"
#import "SWAnnotationDetailViewController.h"

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
    self.annotationViews = [NSMutableArray new];
    self.tv.tableFooterView = [UIView new];
    self.tv.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.post) [self identifyAnnotations];
}

- (void)identifyAnnotations
{
    @synchronized(self.annotationViews) {
        self.annotationViews = [SWAnnotationView annotationViewsFromPost:self.post includeAuto:TRUE];
    }
    [self.tv reloadData];
}
     
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2 + self.annotationViews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return [SWPostCell heightForPost:self.post];
    if (indexPath.row == 1) return 84.0;
    
    SWAnnotationView *annotationView = [self.annotationViews objectAtIndex:indexPath.row - 2];
    KLog(@"Cell height is %f", annotationView.frame.size.height);
    return annotationView.frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [self postCellForIndexPath:indexPath];
        case 1:
            return [self actionCell];
        default:
            return [self annotationCellForIndexPath:indexPath];
    }
}


- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"POST! %@", self.post);
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
            DLog(@"Hash Tag!");
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

- (UITableViewCell *)annotationCellForIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"POST! %@", self.post);
    static NSString *CellIdentifier = @"SWAnnotationCell";
    SWAnnotationCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWAnnotationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    [cell prepareUIWithAnnotationView:[self.annotationViews objectAtIndex:indexPath.row - 2]];
    
    return cell;
}

- (void)replyPressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWComposeViewController *composeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWComposeViewController"];
    Post *replyToPost = (self.post.repost_of ? self.post.repost_of : self.post);
    composeViewController.replyToID = replyToPost.id;
    composeViewController.prefillText = [NSString stringWithFormat:@"@%@ ", self.post.user.username];
    [self.navigationController presentModalViewController:composeViewController animated:TRUE];
}

- (void)repostPressed
{
    Post *selectedPost = (self.post.repost_of ? self.post.repost_of : self.post);

    [SVProgressHUD show];
    if ([selectedPost.you_reposted intValue] == 1) {
        [SWPostAPI unrepostPostID:selectedPost.id completed:^(NSError *error, Post *post, NSDictionary *metadata) {
            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    } else {
        [SWPostAPI repostPostID:selectedPost.id completed:^(NSError *error, Post *post, NSDictionary *metadata) {
            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    }
}

- (void)starPressed
{
    Post *selectedPost = (self.post.repost_of ? self.post.repost_of : self.post);
    
    [SVProgressHUD show];
    if ([selectedPost.you_starred intValue] == 1) {
        [SWPostAPI unstarPostID:selectedPost.id completed:^(NSError *error, Post *post, NSDictionary *metadata) {
            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    } else {
        [SWPostAPI starPostID:selectedPost.id completed:^(NSError *error, Post *post, NSDictionary *metadata) {
            [SVProgressHUD dismiss];
            [self.tv reloadData];
        }];
    }

}

- (void)profilePressed:(UIButton *)sender
{
    Post *selectedPost = (self.post.repost_of ? self.post.repost_of : self.post);

    [self performSegueWithIdentifier:@"SWPostDetailToUserDetail" sender:selectedPost.user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWAnnotationDetailViewController *annotationDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWAnnotationDetailViewController"];
    annotationDetailViewController.annotation = [(SWAnnotationView *)[self.annotationViews objectAtIndex:indexPath.row - 2] annotation];
    
    [self.navigationController pushViewController:annotationDetailViewController animated:TRUE];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWPostDetailToUserDetail"]) {
        SWUserDetailViewController *destinationView = segue.destinationViewController;
        if ([sender isKindOfClass:[NSString class]]) destinationView.userID = (NSString *)sender;
        if ([sender isKindOfClass:[User class]]) destinationView.user = (User *)sender;
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
