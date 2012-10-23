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
#import "SWAppDelegate.h"
#import "SWAnnotationView.h"
#import "SWAnnotationCell.h"
#import "Post.h"
#import "RichText.h"
#import "SWAnnotationDetailViewController.h"

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
    
    self.managedObjectContext = [(SWAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

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

    if (!self.fetchedResultsController) {
        NSManagedObjectContext *context = self.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.fetchBatchSize = 20;
        fetchRequest.entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:context];
        NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"int_id" ascending:NO]];
        [fetchRequest setSortDescriptors:sortDescriptors];
        if (self.feed && self.feed.predicate) fetchRequest.predicate = self.feed.predicate;
        NSLog(@"predicate: %@", self.feed.predicate);
        [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"%dCache", self.feed.type]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:[NSString stringWithFormat:@"%dCache", self.feed.type]];
        self.fetchedResultsController.delegate = self;
        NSError *error;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        if (!success){
            NSLog(@"Fetch Failed!");
        } 
        [self loadPosts];
    }
    
    switch (self.feed.type) {
        case SWFeedTypeMyFeed:
            self.title = @"My Feed";
            break;
        case SWFeedTypeConversation:
            self.title = @"Conversation";
            self.showAnnotations = TRUE;
            break;
        case SWFeedTypeGlobal:
            self.title = @"Global Feed";
            break;
        case SWFeedTypeUserPosts:
            self.title = @"User Posts";
            break;
        case SWFeedTypeUserStars:
            self.title = @"User Starred";
            break;
        case SWFeedTypeUserMentions:
            self.title = @"Mentioning Me";
            break;
        case SWFeedTypeHashtag:
            self.title = @"Hash Feed";
            break;
        default:
            self.title = @"Give me a Title";
            break;
    }
}

- (void)resetPredicate
{
    if (!self.fetchedResultsController) return;
    [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"%dCache", self.feed.type]];
    self.fetchedResultsController.fetchRequest.predicate = self.feed.predicate;
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
    [self.refreshControl beginRefreshing];
    [SVProgressHUD show];
    
    [self.feed loadItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        self.loadingPosts = FALSE;
        [self.refreshControl endRefreshing];
        [SVProgressHUD dismiss];
        [self resetPredicate];
    }];
    
}

- (void)loadOlderPosts
{
    if (self.loadingPosts) return;
    self.loadingPosts = TRUE;
    
    [self.feed loadOlderItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        self.loadingPosts = FALSE;
        [self.refreshControl endRefreshing];
        [self resetPredicate];
    }];
    
}

- (void)loadNewerPosts
{
    if (self.loadingPosts) return;
    self.loadingPosts = TRUE;
    
    [self.feed loadNewerItemsWithBlock:^(NSError *error, NSMutableArray *posts) {
        self.loadingPosts = FALSE;
        [self.refreshControl endRefreshing];
        [self resetPredicate];
    }];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tv deselectRowAtIndexPath:[self.tv indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSLog(@"number of sections: %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.showAnnotations) return 1;
    
    Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:section];
    return [[SWAnnotationView annotationViewsFromPost:post includeAuto:TRUE fullscreen:FALSE] count] + 1;
    
    //Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];

    if (indexPath.row == 0) return [SWPostCell heightForPost:post];

    NSArray *annotationViews = [SWAnnotationView annotationViewsFromPost:post includeAuto:TRUE fullscreen:FALSE];
    SWAnnotationView *annotationView = [annotationViews objectAtIndex:indexPath.row - 1];
    return annotationView.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger postCount = [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];

    if (self.feed.moreItemsAvailable && indexPath.section + 5 > postCount) {
        if (self.reversedFeed) {
            [self loadNewerPosts];
        } else {
            [self loadOlderPosts];
        }
    }    
    if (indexPath.row == 0) {
        return [self postCellForIndexPath:indexPath];
    } else {
        KLog(@"indexPath: %i, %i", indexPath.row, indexPath.section);
        return [self annotationCellForIndexPath:indexPath];
    }
}

- (UITableViewCell *)annotationCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWAnnotationCell";
    SWAnnotationCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWAnnotationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    NSArray *annotationViews = [SWAnnotationView annotationViewsFromPost:post includeAuto:TRUE fullscreen:FALSE];
    
    [cell prepareUIWithAnnotationView:[annotationViews objectAtIndex:indexPath.row - 1]];
    return cell;
}

- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger postCount = [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
    if (indexPath.section >= postCount) return [UITableViewCell new];
    
    static NSString *CellIdentifier = @"SWPostCell";
    SWPostCell *cell = [self.tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    
    if (self.feed.type == SWFeedTypeConversation) {
        cell.suppressConversationMarker = TRUE;
        cell.marked = ([post.id isEqualToString:self.feed.keyID]);
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

    Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    NSLog(@"Hm? %@", post.text.text);
    
    if (indexPath.row > 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SWAnnotationDetailViewController *annotationDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWAnnotationDetailViewController"];
        NSArray *annoViews = [SWAnnotationView annotationViewsFromPost:post includeAuto:FALSE fullscreen:TRUE];
        annotationDetailViewController.annotationView = (SWAnnotationView *)[annoViews objectAtIndex:indexPath.row - 1];
        [self.navigationController pushViewController:annotationDetailViewController animated:TRUE];
    } else {
        BOOL threadExists = (post.num_replies != @0 || post.reply_to);
        if (self.feed.type == SWFeedTypeConversation || !threadExists){
            [self performSegueWithIdentifier:@"SWFeedToPostDetail" sender:self];
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWFeedViewController *threadViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWFeedViewController"];
            threadViewController.feed = [SWFeed feedWithType:SWFeedTypeConversation keyID:post.thread_id];
            [self.navigationController pushViewController:threadViewController animated:TRUE];
        }
    }
}

- (void)profilePressed:(UIButton *)sender
{
    Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:sender.tag];
    if (post.repost_of) post = post.repost_of;
    
    //NSLog(@"POST: %@, USER: %@", post, post.user);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWUserDetailViewController *userViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWUserDetailViewController"];
    userViewController.user = post.user;
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
        Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:[self.tv indexPathForSelectedRow].section];
        destinationView.post = post;
    }
}


- (NSDate *)dateForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tv indexPathForCell:cell];
    Post *post = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    
    NSDate *date = post.created_at;
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tv beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tv insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tv deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tv insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.row]  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tv deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"Fix me!");
            //[self.tv cellForRowAtIndexPath:indexPath];
            [self.tv reloadData];
            break;
        case NSFetchedResultsChangeMove:
            [self.tv deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            [self.tv insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tv endUpdates];
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
