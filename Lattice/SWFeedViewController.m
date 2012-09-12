//
//  SWFeedViewController.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWFeedViewController.h"
#import "SWPostDetailViewController.h"
#import "SWPostCell.h"
#import "SWPostAPI.h"
#import "SWHelpers.h"
#import "SVProgressHUD.h"
#import "SWUserDetailViewController.h"

@interface SWFeedViewController ()

@end

@implementation SWFeedViewController

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
	self.timeScroller = [[TimeScroller alloc] initWithDelegate:self];
    self.tv.tableFooterView = [UIView new];
    self.tv.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];

    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tv];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh:) forControlEvents:UIControlEventValueChanged];


}
- (void)pulledToRefresh:(ODRefreshControl *)control
{    
    [self loadPosts];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPosts];
}

- (void)loadPosts
{
    if (self.posts.count == 0) [SVProgressHUD show];
    [self.refreshControl beginRefreshing];
    if (self.threadID) {
        self.navigationItem.title = @"Conversation";
        [SWPostAPI getThreadWithID:self.threadID min:nil max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
            [self.refreshControl endRefreshing];
            [SVProgressHUD dismiss];
            @synchronized(self.posts) {
                self.posts = posts;
            }
            self.minID = [metadata objectForKey:@"min_id"];
            self.maxID = [metadata objectForKey:@"min_id"];
            self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];

            if (self.morePostsAvailable) NSLog(@"More available!");
            else NSLog(@"Nope.");
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.tv reloadData];
            });
        }];
    } else {
        [SWPostAPI getFeedWithMin:nil max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
            [self.refreshControl endRefreshing];
            [SVProgressHUD dismiss];
            
            @synchronized(self.posts) {
                self.posts = posts;
            }
            
            self.minID = [metadata objectForKey:@"min_id"];
            self.maxID = [metadata objectForKey:@"min_id"];
            self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
            
            if (self.morePostsAvailable) NSLog(@"More available!");
            else NSLog(@"Nope.");
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.tv reloadData];
            });
        }];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tv deselectRowAtIndexPath:[self.tv indexPathForSelectedRow] animated:YES];
}


- (UITableView *)tableViewForTimeScroller:(TimeScroller *)timeScroller {
    return self.tv;
}

- (NSDate *)dateForCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tv indexPathForCell:cell];
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
    NSDate *date = [SWHelpers dateFromRailsDateString:[post objectForKey:@"created_at"]];
    return date;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.posts) return 0;
    return self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.posts || self.posts.count == 0) return 100.0;
    return [SWPostCell heightForPost:[self.posts objectAtIndex:indexPath.row]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self postCellForIndexPath:indexPath];
}


- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWPostCell";
    SWPostCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];

    [cell prepareUIWithPost:post];
    
    cell.profileButton.tag = indexPath.row;
    [cell.profileButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.profileButton addTarget:self action:@selector(profilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([(NSString *)[post objectForKey:@"id"] isEqualToString:self.threadID]) cell.contentView.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];
    else cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
    BOOL threadExists = ([post objectForKey:@"num_replies"] != @0 || [post objectForKey:@"reply_to"]);
    //If we're in a thread, go to item detail
    if (self.threadID || !threadExists){
        [self performSegueWithIdentifier:@"SWFeedToPostDetail" sender:self];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWFeedViewController *threadViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
        
        threadViewController.threadID = [post objectForKey:@"id"];
        [self.navigationController pushViewController:threadViewController animated:TRUE];
    }
}

- (void)profilePressed:(UIButton *)sender
{
    NSDictionary *post = [self.posts objectAtIndex:sender.tag];
    [self performSegueWithIdentifier:@"SWFeedToUserDetail" sender:[post objectForKey:@"user"]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWFeedToPostDetail"]) {
        SWPostDetailViewController *destinationView = segue.destinationViewController;
        NSDictionary *post = [self.posts objectAtIndex:[self.tv indexPathForSelectedRow].row];
        destinationView.post = post;
    } else if ([[segue identifier] isEqualToString:@"SWFeedToUserDetail"]) {
        SWUserDetailViewController *destinationView = segue.destinationViewController;
        destinationView.user = (NSDictionary *)sender;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_timeScroller scrollViewDidScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_timeScroller scrollViewDidEndDecelerating];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timeScroller scrollViewWillBeginDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [_timeScroller scrollViewDidEndDecelerating];
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
