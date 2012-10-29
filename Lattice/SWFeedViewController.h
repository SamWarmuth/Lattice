//
//  SWFeedViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeScroller.h"
#import "SWFeed.h"
#import "ODRefreshControl.h"

@interface SWFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TimeScrollerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet UITableView *tv;
@property (nonatomic, strong) UIView *dateOverlay;
@property (nonatomic, strong) UILabel *dateOverlayTimeLabel, *dateOverlayDateLabel;
@property (nonatomic, strong) TimeScroller *timeScroller;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) SWFeed *feed;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property BOOL loadingPosts, isScrollingQuickly, viewUserPosts, viewUserStarred, viewUserMentions, reversedFeed, showAnnotations;
@property CGPoint lastTableViewOffset;
@property NSTimeInterval lastOffsetCapture;

@property CGFloat loadingCellHeight;

- (IBAction)scrollToTopPressed:(id)sender;


@end
