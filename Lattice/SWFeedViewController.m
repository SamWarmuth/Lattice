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
#import "SWWebViewController.h"

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
    self.tv.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];

    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tv];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.loadingCellHeight = 140.0;

}
- (void)pulledToRefresh:(ODRefreshControl *)control
{    
    [self loadNewerPosts];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.posts || self.posts.count == 0) [self loadPosts];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)loadPosts
{
    if (self.loadingPosts) return;
    self.loadingPosts = TRUE;
    if (self.posts.count == 0) [SVProgressHUD show];
    [self.refreshControl beginRefreshing];
    
    if (self.threadID) {
        [self loadPostsInThread];
    } else if (self.viewUserPosts) {
        [self loadUserPosts];
    } else if (self.viewUserStarred) {
        [self loadUserStarredPosts];
    } else if (self.hashTag) {
        [self loadPostsWithHashtag];
    } else {
        [self loadPostsInFeed];
    }
}

- (void)loadOlderPosts
{
    if (!self.morePostsAvailable || self.loadingPosts) return;
    self.loadingPosts = TRUE;
    if (self.posts.count == 0) [SVProgressHUD show];
    
    if (self.threadID) {
        [self loadOlderPostsInThread];
    } else if (self.viewUserPosts) {
        [self loadOlderUserPosts];
    } else if (self.viewUserStarred) {
        [self loadOlderUserStarredPosts];
    } else if (self.hashTag) {
        [self loadOlderPostsWithHashtag];
    } else {
        [self loadOlderPostsInFeed];
    }
}

- (void)loadNewerPosts
{
    if (self.loadingPosts) return;
    self.loadingPosts = TRUE;
    if (self.posts.count == 0) [SVProgressHUD show];
    
    
    if (self.threadID) {
        [self loadNewerPostsInThread];
    } else if (self.viewUserPosts) {
        [self loadNewerUserPosts];
    } else if (self.viewUserStarred) {
        [self loadNewerUserStarredPosts];
    } else if (self.hashTag) {
        [self loadNewerPostsWithHashtag];
    } else {
        [self loadNewerPostsInFeed];
    }
}


// Feed

- (void)loadPostsInFeed
{
    [SWPostAPI getFeedWithMin:nil max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self replacePostsInTableWithPosts:posts];
    }];
}

- (void)loadNewerPostsInFeed
{
    [SWPostAPI getFeedWithMin:self.maxID max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        if (posts.count != 0) self.maxID = [metadata objectForKey:@"max_id"];
        [self addPostsToBeginningOfTable:posts];
    }];
}

- (void)loadOlderPostsInFeed
{
    [SWPostAPI getFeedWithMin:nil max:self.minID completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self addPostsToEndOfTable:posts];
    }];
}


// Thread

- (void)loadPostsInThread
{
    self.navigationItem.title = @"Conversation";
    [SWPostAPI getThreadWithID:self.threadID min:nil max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self replacePostsInTableWithPosts:posts];
    }];
}

- (void)loadNewerPostsInThread
{
    self.navigationItem.title = @"Conversation";
    [SWPostAPI getThreadWithID:self.threadID min:self.maxID max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        if (posts.count != 0) self.maxID = [metadata objectForKey:@"max_id"];
        [self addPostsToBeginningOfTable:posts];
    }];
}


- (void)loadOlderPostsInThread
{
    self.navigationItem.title = @"Conversation";
    [SWPostAPI getThreadWithID:self.threadID min:nil max:self.minID completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self addPostsToEndOfTable:posts];
    }];
}

// User Posts

- (void)loadUserPosts
{
    self.navigationItem.title = @"User Posts";
    [SWPostAPI getUserPostsWithID:self.userID min:nil max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self replacePostsInTableWithPosts:posts];
    }];
}

- (void)loadNewerUserPosts
{
    self.navigationItem.title = @"User Posts";
    [SWPostAPI getUserPostsWithID:self.userID min:self.maxID max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        if (posts.count != 0) self.maxID = [metadata objectForKey:@"max_id"];
        [self addPostsToBeginningOfTable:posts];
    }];
}

- (void)loadOlderUserPosts
{
    self.navigationItem.title = @"User Posts";
    [SWPostAPI getUserPostsWithID:self.userID min:nil max:self.minID completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self addPostsToEndOfTable:posts];
    }];
}

// User Starred

- (void)loadUserStarredPosts
{
    self.navigationItem.title = @"Starred";
    [SWPostAPI getUserStarredWithID:self.userID min:nil max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self replacePostsInTableWithPosts:posts];
    }];
}

- (void)loadNewerUserStarredPosts
{
    self.navigationItem.title = @"Starred";
    [SWPostAPI getUserStarredWithID:self.userID min:self.maxID max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        if (posts.count != 0) self.maxID = [metadata objectForKey:@"max_id"];
        [self addPostsToBeginningOfTable:posts];
    }];
}

- (void)loadOlderUserStarredPosts
{
    self.navigationItem.title = @"Starred";
    [SWPostAPI getUserStarredWithID:self.userID min:nil max:self.minID completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self addPostsToEndOfTable:posts];
    }];
}


// Hashtags

- (void)loadPostsWithHashtag
{
    self.navigationItem.title = self.hashTag;
    [SWPostAPI getPostsWithHashtag:self.hashTag min:nil max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.maxID = [metadata objectForKey:@"max_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self replacePostsInTableWithPosts:posts];
    }];
}

- (void)loadNewerPostsWithHashtag
{
    self.navigationItem.title = self.hashTag;
    [SWPostAPI getPostsWithHashtag:self.hashTag min:self.maxID max:nil completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        if (posts.count != 0) self.maxID = [metadata objectForKey:@"max_id"];
        [self addPostsToBeginningOfTable:posts];
    }];
}


- (void)loadOlderPostsWithHashtag
{
    self.navigationItem.title = self.hashTag;
    [SWPostAPI getPostsWithHashtag:self.hashTag min:nil max:self.minID completed:^(NSError *error, NSMutableArray *posts, NSDictionary *metadata) {
        self.minID = [metadata objectForKey:@"min_id"];
        self.morePostsAvailable = [[[metadata objectForKey:@"more"] stringValue] isEqualToString:@"1"];
        [self addPostsToEndOfTable:posts];
    }];
}


- (void)replacePostsInTableWithPosts:(NSMutableArray *)posts
{
    [self.refreshControl endRefreshing];
    [SVProgressHUD dismiss];
    self.loadingPosts = FALSE;
    
    @synchronized(self.posts) {
        self.posts = posts;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tv reloadData];
    });
}

- (void)addPostsToEndOfTable:(NSMutableArray *)posts
{
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    self.loadingPosts = FALSE;
    if (posts.count == 0) return;
    
    NSInteger oldPostCount = self.posts.count;
    
    @synchronized(self.posts) {
        self.posts = [[self.posts arrayByAddingObjectsFromArray:posts] mutableCopy];
    }
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = 0; i < posts.count; i++){
        [indexPaths addObject:[NSIndexPath indexPathForRow:oldPostCount + i inSection:0]];
    }
    if (indexPaths.count != posts.count){
        [self.tv reloadData];
        return;
    }
    [self.tv beginUpdates];
    if (!self.morePostsAvailable){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:oldPostCount inSection:0];
        [self.tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
    [self.tv insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tv endUpdates];
}

- (void)addPostsToBeginningOfTable:(NSMutableArray *)posts
{
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    self.loadingPosts = FALSE;
    if (posts.count == 0) return;
    
    @synchronized(self.posts) {
        self.posts = [[posts arrayByAddingObjectsFromArray:self.posts] mutableCopy];
    }
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = 0; i < posts.count; i++){
        [indexPaths addObject:[NSIndexPath indexPathForRow:i  inSection:0]];
    }
    
    [self.tv beginUpdates];
    [self.tv insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [self.tv endUpdates];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tv deselectRowAtIndexPath:[self.tv indexPathForSelectedRow] animated:YES];
}




- (NSDate *)dateForCell:(UITableViewCell *)cell {
    
    if (self.posts.count == 0) return nil;
    
    NSIndexPath *indexPath = [self.tv indexPathForCell:cell];
    NSDictionary *post = [self.posts objectAtIndex:MIN(indexPath.row, self.posts.count - 1)];
    NSDate *date = [SWHelpers dateFromRailsDateString:[post objectForKey:@"created_at"]];
    return date;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.posts) return 0;
    
    if (self.morePostsAvailable) return self.posts.count + 1;
    return self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.posts || self.posts.count == 0) return 100.0;
    if (indexPath.row >= self.posts.count) return self.loadingCellHeight;
    return [SWPostCell heightForPost:[self.posts objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.morePostsAvailable && indexPath.row + 15 > self.posts.count) [self loadOlderPosts];
    
    
    if (indexPath.row >= self.posts.count) return [self loadingCellForIndexPath:indexPath];
    return [self postCellForIndexPath:indexPath];
}


- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.posts.count) return [UITableViewCell new];
    
    static NSString *CellIdentifier = @"SWPostCell";
    SWPostCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
    cell.suppressConversationMarker = (!!self.threadID);
    cell.marked = ([(NSString *)[post objectForKey:@"id"] isEqualToString:self.threadID]);

    [cell prepareUIWithPost:post];
    
    [cell handleLinkTappedWithBlock:^(NSTextCheckingResult *linkInfo) {
        NSString *firstCharacter = [[linkInfo.URL absoluteString] substringToIndex:1];
        if ([firstCharacter isEqualToString:@"@"]) {
            NSString *userID = [linkInfo.URL absoluteString];
            [self performSegueWithIdentifier:@"SWFeedToUserDetail" sender:userID];
        } else if ([firstCharacter isEqualToString:@"#"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
            feedViewController.hashTag = [linkInfo.URL absoluteString];
            [self.navigationController pushViewController:feedViewController animated:TRUE];
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWWebViewController *webController = [storyboard instantiateViewControllerWithIdentifier:@"SWWebViewController"];
            webController.initialURL = linkInfo.URL;
            [self.navigationController pushViewController:webController animated:TRUE];
        }

    }];
    
    cell.profileButton.tag = indexPath.row;
    [cell.profileButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.profileButton addTarget:self action:@selector(profilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    if (indexPath.row >= self.posts.count) return;

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_timeScroller scrollViewDidScroll];
    
    return;
    //this calculates if we're moving quickly, to display the dateoverlay
    CGPoint currentOffset = self.tv.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - self.lastTableViewOffset.y;
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabsf(scrollSpeedNotAbs);
        if (scrollSpeed > 1.25) {
            self.isScrollingQuickly = YES;
            [self setDateOverlayVisible:TRUE animated:TRUE];
        } else {
            self.isScrollingQuickly = NO;
            [self setDateOverlayVisible:FALSE animated:TRUE];
        }
        self.lastTableViewOffset = currentOffset;
        self.lastOffsetCapture = currentTime;
    }
}

- (void)setDateOverlayVisible:(BOOL)visible animated:(BOOL)animated
{
    BOOL currentlyDisplayed = (self.dateOverlay && [self.dateOverlay superview]);
    if (currentlyDisplayed == visible) return;
    
    
    if (visible){
        self.dateOverlay = [[UIView alloc] initWithFrame:CGRectMake(20, 130, 280, 120)];
        self.dateOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.dateOverlay.layer.cornerRadius = 20;
        self.dateOverlay.userInteractionEnabled = FALSE;
        if (animated) {
            self.dateOverlay.alpha = 0.0;
            [self.view addSubview:self.dateOverlay];
            [UIView animateWithDuration:0.15
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 self.dateOverlay.alpha = 1.0;
                             }
                             completion:nil];
        } else {
            [self.view addSubview:self.dateOverlay];
        }
        

    } else {
        if (!self.dateOverlay) return;
        
        if (animated) {
            [UIView animateWithDuration:0.5
                                  delay:0.25
                                options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 self.dateOverlay.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 [self.dateOverlay removeFromSuperview];
                                 self.dateOverlay = nil;
                             }];
        } else {
            [self.dateOverlay removeFromSuperview];
            self.dateOverlay = nil;
        }
        
        
    }
}


- (IBAction)composeButtonPressed:(id)sender
{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWFeedToPostDetail"]) {
        SWPostDetailViewController *destinationView = segue.destinationViewController;
        NSDictionary *post = [self.posts objectAtIndex:[self.tv indexPathForSelectedRow].row];
        destinationView.post = post;
    } else if ([[segue identifier] isEqualToString:@"SWFeedToUserDetail"]) {
        SWUserDetailViewController *destinationView = segue.destinationViewController;
        if ([sender isKindOfClass:[NSString class]]) destinationView.userID = (NSString *)sender;
        if ([sender isKindOfClass:[NSDictionary class]]) destinationView.user = (NSDictionary *)sender;
        
    }
}



- (UITableView *)tableViewForTimeScroller:(TimeScroller *)timeScroller {
    return self.tv;
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
