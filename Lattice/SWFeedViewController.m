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
#import "SWAnnotationView.h"
#import "SWAnnotationCell.h"

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
    
    self.loadingCellHeight = 60.0;

}
- (void)pulledToRefresh:(ODRefreshControl *)control
{
    if (self.reversedFeed) {
        [self loadOlderPosts];
    } else {
        [self loadNewerPosts];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.posts || self.posts.count == 0) [self loadPosts];
    
    switch (self.feed.type) {
        case SWFeedTypeMyFeed:
            self.title = @"My Feed";
            self.showingAnnotations = FALSE;
            break;
        case SWFeedTypeConversation:
            self.title = @"Conversation";
            self.showingAnnotations = TRUE;
            break;
        case SWFeedTypeGlobal:
            self.title = @"Global Feed";
            self.showingAnnotations = FALSE;
            break;
        case SWFeedTypeUserPosts:
            self.title = @"User Posts";
            self.showingAnnotations = FALSE;
            break;
        case SWFeedTypeUserStars:
            self.title = @"User Starred";
            self.showingAnnotations = FALSE;
            break;
        case SWFeedTypeUserMentions:
            self.title = @"Mentioning Me";
            self.showingAnnotations = FALSE;
            break;
        default:
            self.title = @"Give me a Title";
            self.showingAnnotations = FALSE;
            break;
    }
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
    
    
    [self.feed loadItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        [self replacePostsInTableWithPosts:posts];
    }];
    
}

- (void)loadOlderPosts
{
    if (self.loadingPosts) return;
    self.loadingPosts = TRUE;
    if (self.posts.count == 0) [SVProgressHUD show];
    
    [self.feed loadOlderItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        [self addPostsToEndOfTable:posts];
    }];
    
}

- (void)loadNewerPosts
{
    if (self.loadingPosts) return;
    self.loadingPosts = TRUE;
    if (self.posts.count == 0) [SVProgressHUD show];
    
    [self.feed loadNewerItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        KLog(@"%i current, %i new", self.posts.count, posts.count);
        [self addPostsToBeginningOfTable:posts];
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
        [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:oldPostCount + i]];
    }

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tv beginUpdates];
        if (!self.feed.moreItemsAvailable) {
            [self.tv deleteSections:[NSIndexSet indexSetWithIndex:oldPostCount] withRowAnimation:UITableViewRowAnimationNone];
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(oldPostCount, posts.count)];
        [self.tv insertSections:indexSet withRowAnimation:UITableViewRowAnimationBottom];
        [self.tv endUpdates];
    });
}

- (void)addPostsToBeginningOfTable:(NSMutableArray *)posts
{
    //posts.count adds 40 straight up..... every other time?
    
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    self.loadingPosts = FALSE;
    if (posts.count == 0) return;
    
    @synchronized(self.posts) {
        self.posts = [[posts arrayByAddingObjectsFromArray:self.posts] mutableCopy];
    }

    [self.tv reloadData];
    
    /*
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //KLog(@"Num of sect : %i", self.tv.numberOfSections);
        //[self.tv beginUpdates];
        //NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)];
        //KLog(@"indexSet: %@", indexSet);
        //[self.tv insertSections:indexSet withRowAnimation:UITableViewRowAnimationBottom];
        //[self.tv endUpdates];
        //KLog(@"Num of sect : %i", self.tv.numberOfSections);
    });
     
     */
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tv deselectRowAtIndexPath:[self.tv indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.posts) return 0;
    
    if (self.feed.moreItemsAvailable) return self.posts.count + 1;
    return self.posts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((section == [self numberOfSectionsInTableView:tableView] - 1 && self.feed.moreItemsAvailable) || !self.showingAnnotations) return 1;
    return 1 + [[SWAnnotationView annotationViewsFromPostDictionary:[self.posts objectAtIndex:section] includeAuto:TRUE] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.posts || self.posts.count == 0) return 100.0;
    if (indexPath.section >= self.posts.count) return self.loadingCellHeight;
    if (indexPath.row == 0)return [SWPostCell heightForPost:[self.posts objectAtIndex:indexPath.section]];
    
    NSDictionary *post = [self.posts objectAtIndex:indexPath.section];
    NSArray *annoViews = [SWAnnotationView annotationViewsFromPostDictionary:post includeAuto:TRUE];
    
    SWAnnotationView *annotationView = [annoViews objectAtIndex:indexPath.row - 1];
    return annotationView.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.feed.moreItemsAvailable && indexPath.section + 5 > self.posts.count) {
        if (self.reversedFeed) {
            [self loadNewerPosts];
        } else {
            [self loadOlderPosts];
        }
    }
    if (indexPath.section >= self.posts.count) {
        return [self loadingCellForIndexPath:indexPath];
    } else if (indexPath.row != 0) {
        KLog(@"indexPath:%i,%i", indexPath.row, indexPath.section);
        return [self annotationCellForIndexPath:indexPath];
    }
    return [self postCellForIndexPath:indexPath];
}

- (UITableViewCell *)annotationCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWAnnotationCell";
    SWAnnotationCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWAnnotationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *post = [self.posts objectAtIndex:indexPath.section];
    NSArray *annoViews = [SWAnnotationView annotationViewsFromPostDictionary:post includeAuto:TRUE];
    
    [cell prepareUIWithAnnotationView:[annoViews objectAtIndex:indexPath.row - 1]];
    
    return cell;
}

- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.posts.count) return [UITableViewCell new];
    
    static NSString *CellIdentifier = @"SWPostCell";
    SWPostCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *post = [self.posts objectAtIndex:indexPath.section];
    if (self.feed.type == SWFeedTypeConversation) {
        cell.suppressConversationMarker = TRUE;
        cell.marked = ([(NSString *)[post objectForKey:@"id"] isEqualToString:self.feed.keyID]);
    }


    [cell prepareUIWithPost:post];
    
    if (self.feed.type == SWFeedTypeUserStars)
    {
        if (cell.marked) cell.contentView.backgroundColor = [UIColor colorWithRed:0.957 green:0.957 blue:0.957 alpha:1];
        else cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    [cell handleLinkTappedWithBlock:^(NSTextCheckingResult *linkInfo) {
        NSString *firstCharacter = [[linkInfo.URL absoluteString] substringToIndex:1];
        if ([firstCharacter isEqualToString:@"@"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWUserDetailViewController *userViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWUserDetailViewController"];
            userViewController.userID = [linkInfo.URL absoluteString];
            [self.navigationController pushViewController:userViewController animated:TRUE];
        } else if ([firstCharacter isEqualToString:@"#"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWFeedViewController *feedViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
            KLog(@"%@",[linkInfo.URL absoluteString]);
            feedViewController.feed = [SWFeed feedWithType:SWFeedTypeHashtag keyID:[[linkInfo.URL absoluteString] substringFromIndex:1]];
            [self.navigationController pushViewController:feedViewController animated:TRUE];
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWWebViewController *webController = [storyboard instantiateViewControllerWithIdentifier:@"SWWebViewController"];
            webController.initialURL = linkInfo.URL;
            [self.navigationController pushViewController:webController animated:TRUE];
        }
    }];
    
    cell.profileButton.tag = indexPath.section;
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
    cell.contentView.backgroundColor = self.tv.backgroundColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.posts.count || indexPath.row != 0) return;

    NSDictionary *post = [self.posts objectAtIndex:indexPath.section];
    BOOL threadExists = ([post objectForKey:@"num_replies"] != @0 || [post objectForKey:@"reply_to"]);
    //If we're in a thread, go to item detail
    if (self.feed.type == SWFeedTypeConversation || !threadExists){
        [self performSegueWithIdentifier:@"SWFeedToPostDetail" sender:self];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWFeedViewController *threadViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
        threadViewController.feed = [SWFeed feedWithType:SWFeedTypeConversation keyID:[post objectForKey:@"id"]];
        [self.navigationController pushViewController:threadViewController animated:TRUE];
    }
}

- (void)profilePressed:(UIButton *)sender
{
    NSDictionary *post = [self.posts objectAtIndex:sender.tag];    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWUserDetailViewController *userViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWUserDetailViewController"];
    userViewController.user = [post objectForKey:@"user"];
    [self.navigationController pushViewController:userViewController animated:TRUE];
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
        NSDictionary *post = [self.posts objectAtIndex:[self.tv indexPathForSelectedRow].section];
        destinationView.post = post;
    }
}


- (NSDate *)dateForCell:(UITableViewCell *)cell {
    
    if (self.posts.count == 0) return nil;
    
    NSIndexPath *indexPath = [self.tv indexPathForCell:cell];
    NSDictionary *post = [self.posts objectAtIndex:MIN(indexPath.section, self.posts.count - 1)];
    NSDate *date = [SWHelpers dateFromRailsDateString:[post objectForKey:@"created_at"]];
    return date;
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == _timeScroller.scrollContainer){
        BOOL success = [_timeScroller scrollbarTouchesBegan:touch];
        if (success) return;
        DLog(@"NOOOOOO");
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == _timeScroller.scrollContainer){
        BOOL success = [_timeScroller scrollBarTouchesMoved:touch];
        if (success) return;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == _timeScroller.scrollContainer){
        BOOL success = [_timeScroller scrollbarTouchesEnded:touch];
        if (success) return;
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
