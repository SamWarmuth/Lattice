//
//  SWFeedViewController.h
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeScroller.h"
#import "ODRefreshControl.h"

@interface SWFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TimeScrollerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tv;
@property (nonatomic, strong) UIView *dateOverlay;
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSString *threadID, *userID, *minID, *maxID;
@property (nonatomic, strong) TimeScroller *timeScroller;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property BOOL morePostsAvailable, loadingPosts, isScrollingQuickly, viewUserPosts, viewUserStarred, viewUserMentions;
@property CGPoint lastTableViewOffset;
@property NSTimeInterval lastOffsetCapture;

@property CGFloat loadingCellHeight;

- (IBAction)composeButtonPressed:(id)sender;


@end
